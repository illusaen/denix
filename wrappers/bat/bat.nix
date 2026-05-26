{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.modules.default ];
  options.renderScheme = lib.mkOption {
    type = lib.types.raw;
    description = "base16 scheme renderer";
  };
  config.package = pkgs.bat;
  config.env.BAT_CONFIG_DIR = dirOf config.constructFiles.generatedConfig.path;
  config.constructFiles = {
    generatedConfig = {
      content = ''
        --theme="Base16-custom"
        --italic-text=always
      '';
      relPath = "config";
    };
    themeConfig =
      let
        bat-theme = config.renderScheme {
          inherit pkgs lib;
          template = ./bat.tmTheme.mustache;
          extension = "tmTheme";
        };
      in
      {
        relPath = "themes/Base16-custom.tmTheme";
        builder = ''
          mkdir -p "$(dirname "$2")"
          ln -s ${lib.escapeShellArg bat-theme} "$2"
        '';
      };
  };
}
