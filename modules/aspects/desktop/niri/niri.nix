{
  den,
  inputs,
  ...
}:
{
  den.aspects.desktop._.niri = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        nix.settings = {
          substituters = [ "https://niri.cachix.org" ];
          trusted-public-keys = [
            "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
          ];
        };

        programs.niri = {
          enable = true;
          package = inputs.nixpkgs-master.legacyPackages.${pkgs.stdenv.hostPlatform.system}.niri;
        };

        services.displayManager.defaultSession = "niri";

        environment.systemPackages = with pkgs; [
          xwayland-satellite
        ];

        environment.sessionVariables = {
          GDK_BACKEND = "wayland,x11,*";
          NIXOS_OZONE_WL = "1";
          QT_QPA_PLATFORM = "wayland";
          QT_QPA_PLATFORMTHEME = "qt5ct";
          QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
          XDG_SESSION_DESKTOP = "niri";
          XDG_SESSION_TYPE = "wayland";
        };

        xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };

    hj =
      { pkgs, osConfig, ... }:
      let
        mainMonitor = "LG Electronics LG ULTRAGEAR+ 508RMWVJR505";
        secondaryMonitor = "Philips Consumer Electronics Company PHL 288E2 UK52215001852";
      in
      {
        xdg.config.files."niri/config.kdl".source = pkgs.replaceVars ./config.kdl {
          cursorTheme = osConfig.myLib.theming.cursorTheme.name;
          cursorSize = osConfig.myLib.theming.cursorTheme.size;
          inherit mainMonitor secondaryMonitor;
        };
      };
  };
}
