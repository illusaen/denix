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
        inherit (fleet.my) monitors;
      };
    };

    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.local.waybar ];
      systemd.packages = [ pkgs.local.waybar ];
      systemd.user.services.waybar = {
        wantedBy = [ "graphical-session.target" ];
        after = [ "swaync.service" ];
      };
    };
  };
}
