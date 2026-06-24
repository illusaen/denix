{rootPath, ...}: {
  den.aspects.display-manager.waybar = {
    wrapper-packages = {host, ...}: {
      waybar = let
        fonts = host.settings.base.fonts;
        base16 = host.settings.base.base16;
        monitors = host.settings."display-manager".monitor;
      in {
        imports = [(rootPath + /wrappers/waybar/waybar.nix)];
        scheme = base16.scheme.withHashtag;
        font = {
          inherit (fonts) sans mono icon;
          size = fonts.sizes.applications;
        };
        monitors = {
          main = monitors.main.connector;
          secondary = monitors.secondary.connector;
        };
      };
    };

    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.local.waybar];
      systemd.packages = [pkgs.local.waybar];
      systemd.user.services.waybar = {
        wantedBy = ["graphical-session.target"];
        after = ["swaync.service"];
      };
    };
  };
}
