{
  wlib,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [wlib.modules.default];

  options.accountName = lib.mkOption {type = lib.types.str;};

  config = {
    env.GH_CONFIG_DIR = dirOf config.constructFiles.generatedConfig.path;
    package = pkgs.gh;
    constructFiles = {
      generatedConfig = {
        content = ''
          version: "1"
        '';
        relPath = "config.yml";
      };
      generatedHosts = {
        content = ''
          github.com:
            git_protocol: ssh
            users:
              ${config.accountName}:
            user: ${config.accountName}
        '';
        relPath = "hosts.yml";
      };
    };
  };
}
