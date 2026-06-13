{ rootPath, lib, ... }:
{
  options.fleet.my.wallpaper = lib.mkOption {
    type = lib.types.path;
    default = rootPath + /resources/gold-dragon.jpeg;
  };

  config.den.aspects.programs.wallpaper = {
    nixos =
      {
        pkgs,
        lib,
        fleet,
        ...
      }:
      {
        systemd.user.services.swaybg = {
          description = "Cosmic tree desktop background";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session-pre.target" ];
          serviceConfig = {
            ExecStart = "${lib.getExe pkgs.swaybg} -i ${fleet.my.wallpaper} -m fill";
            Restart = "on-failure";
          };
        };
      };

    darwin = { fleet, ... }: {
      system.activationScripts.setDesktopBackground = ''
        echo "Setting desktop background."
        osascript -e 'tell application "System Events" to tell every desktop to set picture to "${fleet.my.wallpaper}"'
      '';
    };
  };
}
