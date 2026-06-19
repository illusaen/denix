{
  wlib,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [ wlib.modules.default ];

  options.imageDirectory = lib.mkOption { type = lib.types.path; };

  config = {
    package = pkgs.wpaperd;
    env.XDG_CONFIG_HOME = placeholder "out";
    constructFiles = {
      generatedConfig = {
        content = ''
          [default]
          path = "${config.imageDirectory}"
          duration = "30m"
          mode = "stretch"

          [default.transition.directional-wipe]
        '';
        relPath = "wpaperd/config.toml";
      };
    };
  };
}
