{rootPath, ...}: {
  den.aspects.display-manager.waybar = {
    wrapper-packages = {fleet, ...}: {
      waybar = let
        inherit (fleet.my) fonts base16 monitors;
      in {
        imports = [(rootPath + /wrappers/waybar/waybar.nix)];
        scheme = base16.scheme.withHashtag;
        font = {
          inherit (fonts) sans mono icon;
          size = fonts.sizes.applications;
        };
        monitors = monitors.connectors;
      };
    };

    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.local.waybar];
      systemd.packages = [pkgs.local.waybar];
      systemd.user.services.waybar.wantedBy = ["graphical-session.target"];
    };
  };
}
