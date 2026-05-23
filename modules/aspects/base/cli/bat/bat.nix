{
  den,
  self,
  inputs,
  ...
}:
{
  den.aspects.base.cli.includes = with den.aspects.base.cli; [ bat ];

  den.aspects.base.cli.bat = {
    os =
      { pkgs, lib, ... }:
      let
        bat-theme = self.my.scheme {
          template = ./bat.tmTheme.mustache;
          extension = "tmTheme";
        };

        bat-wrapped = inputs.wrappers.lib.wrapPackage (
          { config, ... }:
          {
            inherit pkgs; # you can only grab the final package if you supply pkgs!
            package = pkgs.bat;
            env.BAT_CONFIG_DIR = dirOf config.constructFiles.generatedConfig.path;
            constructFiles = {
              generatedConfig = {
                content = ''
                  --theme="Base16-custom"
                  --italic-text=always
                '';
                relPath = "config";
              };
              themeConfig = {
                relPath = "themes/Base16-custom.tmTheme";
                builder = ''
                  mkdir -p "$(dirname "$2")"
                  ln -s ${lib.escapeShellArg bat-theme} "$2"
                '';
              };
            };
          }
        );
      in
      {
        environment.systemPackages = [ bat-wrapped ];
      };

    provides.to-users.persistUser.directories = [ ".cache/bat" ];
  };
}
