{
  den,
  lib,
  ...
}:
{
  den.ctx.host.includes = [ den.aspects.cli ];

  den.schema.user =
    { lib, ... }:
    {
      options.misc = lib.mkOption {
        default = {
          fullName = "Wendy Chen";
          email = "jaewchen@gmail.com";
          dirs = lib.mkOption {
            default = {
              projects = "$HOME/Projects";
              nix = "$HOME/Projects/nix";
            };
          };
        };
      };
    };

  den.aspects.cli =
    { user, ... }:
    {
      includes = lib.attrValues den.aspects.cli._;

      _.btop =
        { pkgs, ... }:
        let
          btop-wrapped = pkgs.symlinkJoin {
            name = "btop";
            paths = [ pkgs.btop ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              mkdir -p $out/share/themes
              echo "color_theme = \"custom\"" > $out/btop.conf
              wrapProgram $out/bin/btop --add-flag --config --add-flag $out/btop.conf --add-flag --themes-dir --add-flag ${btop-wrapped}/share/themes
            '';
          };
        in
        {
          os.environment.systemPackages = [ btop-wrapped ];
        };

      _.eza =
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
        den.lib.perHost {
          os = {
            environment.systemPackages = [ eza-wrapped ];
            programs.fish.shellAliases = {
              l = "eza -alg";
              ll = "eza --tree --git-ignore --all";
            };
          };
        };

      _.fd =
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
        den.lib.perHost {
          os.environment.systemPackages = [ fd-wrapped ];
        };

      _.packages =
        { pkgs, config, ... }:
        den.lib.perHost {
          os = {
            environment.systemPackages = with pkgs; [
              gh
              coreutils
              vim
            ];

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

      _.bat = den.lib.perHost {
        os.programs.bat.enable = true;
      };

      _.direnv = den.lib.perHost {
        os.programs.direnv = {
          enable = true;
          silent = true;
          nix-direnv.enable = true;
          settings = {
            hide_env_diff = true;
            whitelist.prefix = [ "${user.misc.dirs.projects}" ];
          };
        };
      };

      _.fzf = den.lib.perHost {
        os.programs.fzf.enable = true;
      };

      _.ssh = den.lib.perHost {
        os.programs.ssh.enable = true;
      };

      _.zoxide = den.lib.perHost {
        os.programs.zoxide = {
          enable = true;
          flags = [ "--cmd n" ];
        };
      };

      _.gh =
        { pkgs, ... }:
        den.lib.perHost {
          os = {
            environment.systemPackages = with pkgs; [ gh ];
            environment.sessionVariables = {
              GH_CONFIG_DIR = "/etc/gh";
            };
            environment.etc."gh/config.yml".text = ''
              git_protocol: ssh
            '';
          };
        };

      _.git =
        { lib, pkgs, ... }:
        den.lib.perHost {
          os.programs.git = {
            enable = true;
            config = {
              user.name = user.misc.fullName;
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
    };
}
