{ rootPath, ... }:
{
  den.aspects.display-manager.waybar = {
    wrapper-packages = { fleet, ... }: {
      waybar = {
        imports = [ (rootPath + /wrappers/waybar/waybar.nix) ];
        scheme = fleet.my.base16.scheme.withHashtag;
        font = {
          inherit (fleet.my.fonts) sans mono icon;
          size = fleet.my.fonts.sizes.applications;
        };
      };
    };

    nixos = { pkgs, lib, ... }: {
      environment.systemPackages = [ pkgs.local.waybar ];
      systemd.user.services.waybar = {
        description = "Desktop menu bar";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [
          "graphical-session-pre.target"
          "swaync.service"
        ];
        serviceConfig = {
          ExecStart = lib.getExe pkgs.local.waybar;
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
  };
}
