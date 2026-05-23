{ den, ... }:
{
  den.aspects.base.cli.includes = with den.aspects.base.cli; [ git ];

  den.aspects.base.cli.git = {
    shell = {
      interactiveShellInit = ''
        abbr -a gcm --set-cursor 'git commit -m "%"'
        abbr -a git_clone_own_repo --set-cursor --regex "^g(gc|r)l\$" --function _git_clone_repo
      '';
      shellAbbrs = {
        gst = "git status";
        gco = "git checkout";
        ga = "git add -A";
        gf = "git fetch";
        gl = "git pull";
        gd = "git diff";
        gb = "git branch";
        glg = "git log";
        gp = "git push";
        gpf = "git push --force-with-lease";
      };
    };

    wrapper-packages.git =
      { wlib, ... }:
      {
        imports = [ wlib.wrapperModules.git ];
        settings = {
          core.sshCommand = "ssh -i /etc/ssh/id_rsa";
          diff.external = "difft --color auto --background dark --display side-by-side";
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
          user = {
            email = "jaewchen@gmail.com";
            name = "Wendy Chen";
          };
          credential = {
            helper = "gh auth git-credential";
            username = "illusaen";
          };
        };
      };

    os =
      { pkgs, self', ... }:
      let
        fishGitCloneRepo = pkgs.symlinkJoin {
          name = "fishGitCloneRepo";
          paths = [
            (pkgs.writeTextDir "share/fish/vendor_functions.d/_git_clone_repo.fish" ''
              function _git_clone_repo
                set --local base_url 'git@github.com:illusaen/'
                set --local default_result git clone $base_url'%.git'
                switch $argv[1]
                  case ggcl
                    echo $default_result
                  case grl
                    set --local repo_name (gh repo list | fzf)
                    if test -n "$repo_name" && string match -rq '^.+\/(?<repo>\S+).+$' $repo_name
                      echo git clone $base_url$repo'.git'
                    end
                end
              end
            '')
          ];
        };
      in
      {
        environment.systemPackages = with pkgs; [
          difftastic
          fishGitCloneRepo
          self'.packages.git
        ];
      };
  };
}
