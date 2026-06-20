{
  wlib,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.wrapperModules.git ];

  options = {
    accountName = lib.mkOption { type = lib.types.str; };
    displayName = lib.mkOption { type = lib.types.str; };
    email = lib.mkOption { type = lib.types.str; };
  };

  config = {
    runtimePkgs = with pkgs; [ difftastic ];
    settings = {
      core.sshCommand = "ssh -i /etc/ssh/id_rsa";
      diff.external = "difft --color auto --background dark --display side-by-side";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      user = {
        inherit (config) email;
        name = config.displayName;
      };
      credential = {
        inherit (config) accountName;
        helper = "gh auth git-credential";
      };
    };
    constructFiles."git_clone_repo.fish" = {
      content = ''
        function _git_clone_repo
              set --local base_url 'git@github.com:${config.accountName}/'
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
      '';
      relPath = "share/fish/vendor_functions.d/_git_clone_repo.fish";
    };
  };
}
