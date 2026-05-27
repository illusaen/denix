{ den, self, ... }:
{
  den.aspects.wm.includes = with den.aspects.wm; [ niri ];

  den.aspects.wm.niri = {
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
        };

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

    provides.to-users.hjem =
      { pkgs, ... }:
      let
        mainMonitor = "LG Electronics LG ULTRAGEAR+ 508RMWVJR505";
        secondaryMonitor = "BOE Display 000000001";
        inherit (self.my.theming) cursorTheme;
        inherit (self.my.scheme.withHashtag) base0E;
      in
      {
        xdg.config.files = {
          "niri/config.kdl".source = pkgs.replaceVars ./config.kdl {
            cursorTheme = cursorTheme.name;
            cursorSize = cursorTheme.size;
            inherit mainMonitor secondaryMonitor base0E;
          };
          "niri/animations.kdl".source = ./animations.kdl;
          "niri/binds.kdl".source = ./binds.kdl;
          "niri/layer-rules.kdl".source = ./layer-rules.kdl;
          "niri/window-rules.kdl".source = ./window-rules.kdl;
        };
      };
  };
}
