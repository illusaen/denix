{ rootPath, ... }:
{
  den.aspects.programs.wallpaper =
    let
      wallpaper = rootPath + /resources/cosmic-tree.png;
    in
    {
      nixos = { pkgs, lib, ... }: {
        systemd.user.services.swaybg = {
          description = "Cosmic tree desktop background";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          after = [ "graphical-session-pre.target" ];
          serviceConfig = {
            ExecStart = "${lib.getExe pkgs.swaybg} -i ${wallpaper} -m fill";
            Restart = "on-failure";
          };
        };
      };

      darwin = {
        system.activationScripts.setDesktopBackground = ''
          echo "Setting desktop background."
          osascript -e 'tell application "System Events" to tell every desktop to set picture to "${wallpaper}"'
        '';
      };
    };
}
