{
  wlib,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    wlib.modules.default
    ./service.nix
  ];

  options.imageDirectory = lib.mkOption { type = lib.types.path; };

  config = {
    package = pkgs.wpaperd;
    service.enable = true;
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
