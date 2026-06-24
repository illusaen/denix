{rootPath, ...}: {
  den.aspects.display-manager.swaync = {
    wrapper-packages = {host, ...}: {
      swaync = let
        fonts = host.settings.base.fonts;
        base16 = host.settings.base.base16;
      in {
        imports = [(rootPath + /wrappers/swaync/swaync.nix)];
        font = fonts.sans;
        colors = base16.scheme.withHashtag;
      };
    };

    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs.local; [swaync];
      systemd.packages = [pkgs.local.swaync];
      systemd.user.services.swaync.wantedBy = ["graphical-session.target"];
    };
  };
}
