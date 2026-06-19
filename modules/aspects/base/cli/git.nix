{ den, ... }:
let
  identity = owner: den.users.registry.${owner}.identity;
in
{
  den.aspects.base.cli.git = {
    wrapper-packages =
      { host, ... }:
      {
        git =
          { wlib, ... }:
          let
            inherit (identity host.system-owner) accountName email displayName;
          in
          {
            imports = [ wlib.wrapperModules.git ];
            settings = {
              core.sshCommand = "ssh -i /etc/ssh/id_rsa";
              diff.external = "difft --color auto --background dark --display side-by-side";
              init.defaultBranch = "main";
              pull.rebase = true;
              push.autoSetupRemote = true;
              user = {
                inherit email;
                name = displayName;
              };
              credential = {
                helper = "gh auth git-credential";
                inherit accountName;
              };
            };
          };
      };

    os =
      {
        pkgs,
        host,
        ...
      }:
      let
        fishGitCloneRepo = pkgs.symlinkJoin {
          name = "fishGitCloneRepo";
          paths = [
            (pkgs.writeTextDir "share/fish/vendor_functions.d/_git_clone_repo.fish" ''
              function _git_clone_repo
                set --local base_url 'git@github.com:${(identity host.system-owner).accountName}/'
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
        environment.shellAliases = {
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
        programs.fish.interactiveShellInit = ''
          abbr -a gcm --set-cursor 'git commit -m "%"'
          abbr -a git_clone_own_repo --set-cursor --regex "^g(gc|r)l\$" --function _git_clone_repo
        '';
        environment.systemPackages = with pkgs; [
          difftastic
          fishGitCloneRepo
          local.git
        ];
      };
  };
}
