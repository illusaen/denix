{ den, inputs, ... }:
{
  den.aspects.base.cli.includes = with den.aspects.base.cli; [ gh ];

  den.aspects.base.cli.gh = {
    os =
      { pkgs, ... }:
      let
        gh-wrapped = inputs.wrappers.lib.wrapPackage (
          { config, ... }:
          {
            inherit pkgs; # you can only grab the final package if you supply pkgs!
            package = pkgs.gh;
            env.GH_CONFIG_DIR = dirOf config.constructFiles.generatedConfig.path;
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
                      illusaen:
                    user: illusaen
                '';
                relPath = "hosts.yml";
              };
            };
          }
        );
      in
      {
        environment.systemPackages = [ gh-wrapped ];
      };
  };
}
