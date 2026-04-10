{
  den,
  lib,
  ...
}:
{
  den.ctx.host.includes = [ den.aspects.cli ];

  den.schema.host =
    { lib, ... }:
    {
      options.misc = lib.mkOption {
        default = {
          fullName = "Wendy Chen";
          email = "jaewchen@gmail.com";
          dirs = {
            projects = "$HOME/Projects";
            nix = "$HOME/Projects/nix";
          };
        };
      };
    };

  den.aspects.cli = {
    includes = lib.attrValues den.aspects.cli._;

    _.btop.os =
      { pkgs, ... }:
      let
        btop-wrapped = pkgs.symlinkJoin {
          name = "btop";
          paths = [ pkgs.btop ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out/share/themes
            echo "color_theme = \"custom\"" > $out/btop.conf
            wrapProgram $out/bin/btop --add-flag --config --add-flag $out/btop.conf --add-flag --themes-dir --add-flag $out/share/themes
          '';
        };
      in
      {
        environment.systemPackages = [ btop-wrapped ];
      };

    _.eza.os =
      { pkgs, ... }:
      let
        eza-wrapped = pkgs.symlinkJoin {
          name = "eza";
          paths = [ pkgs.eza ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out
            wrapProgram $out/bin/eza --add-flag --icons --add-flag auto --add-flag --git
          '';
        };
      in
      {
        environment.systemPackages = [ eza-wrapped ];
        programs.fish.shellAliases = {
          l = "eza -alg";
          ll = "eza --tree --git-ignore --all";
        };
      };

    _.fd.os =
      { pkgs, ... }:
      let
        fd-wrapped = pkgs.symlinkJoin {
          name = "eza";
          paths = [ pkgs.fd ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out
            wrapProgram $out/bin/fd --add-flag --hidden --add-flag --follow --add-flag --exclude --add-flag ".git/"
          '';
        };
      in
      {
        environment.systemPackages = [ fd-wrapped ];
      };

    _.packages =
      { host, ... }:
      {
        os =
          { config, pkgs, ... }:
          {
            environment.systemPackages = with pkgs; [
              gh
              coreutils
              vim
            ];

            environment.sessionVariables.NIX_CONF = "${host.misc.dirs.nix}";

            environment.etc."dependencies.txt".text = lib.pipe (config.environment.systemPackages) (
              with builtins;
              [
                (lib.map (p: p.name))
                lib.lists.unique
                (sort lessThan)
                (concatStringsSep "\n")
              ]
            );
          };
      };

    _.bat.os = {
      programs.bat.enable = true;
    };

    _.fzf.os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ fzf ];
      };

    _.zoxide.os = {
      programs.zoxide = {
        enable = true;
        flags = [ "--cmd n" ];
      };
    };

    _.git =
      { host, ... }:
      {
        os =
          {
            lib,
            pkgs,
            ...
          }:
          {
            programs.git = {
              enable = true;
              config = {
                user.name = host.misc.fullName;
                user.email = "jaewchen@gmail.com";
                init.defaultBranch = "main";
                pull.rebase = true;
                push.autoSetupRemote = true;
                diff.external = lib.concatStringsSep " " [
                  "${lib.getExe pkgs.difftastic}"
                  "--color always"
                  "--background dark"
                  "--display side-by-side"
                ];
              };
            };
          };

        hm.programs.fish = {
          shellAbbrs = {
            gst = "git status";
            gcm = {
              setCursor = true;
              expansion = "git commit -m \"%\"";
            };
            gco = "git checkout";
            ga = "git add -A";
            gf = "git fetch";
            gl = "git pull";
            gd = "git diff";
            gb = "git branch";
            glg = "git log";
            gp = "git push";
            gpu = "git push -u origin (git rev-parse --abbrev-ref HEAD)";
            gpf = "git push --force-with-lease";
            git_clone_own_repo = {
              function = "_git_clone_own_repo";
              regex = "^g(gc|r)l\$";
              setCursor = true;
            };
          };

          functions._git_clone_own_repo = ''
            set --local base_url 'git@github.com:illusaen/'
            set --local default_result git clone $base_url'%.git'
            switch $argv
              case ggcl
                echo $default_result
              case grl
                set --local repo_name (gh repo list | fzf)
                if test -n "$repo_name" && string match -rq '^.+\/(?<repo>\S+).+$' $repo_name
                  echo git clone $base_url$repo'.git'
                end
            end
          '';
        };
      };

    _.direnv =
      { host, ... }:
      {
        os = {
          programs.direnv = {
            enable = true;
            silent = true;
            nix-direnv.enable = true;
            settings = {
              hide_env_diff = true;
              whitelist.prefix = [ "${host.misc.dirs.projects}" ];
            };
          };
        };
      };

    _.gh.os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ gh ];
        environment.sessionVariables = {
          GH_CONFIG_DIR = "/etc/gh";
        };
        environment.etc."gh/config.yml".text = ''
          git_protocol: ssh
        '';
      };
  };
}
