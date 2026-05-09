# { inputs, ... }:
{
  flake-file.inputs.hyprland.url = "github:hyprwm/Hyprland/main";

  den.aspects.desktop._.hyprland = {
    nixos =
      { pkgs, ... }:
      {
        programs.hyprland = {
          enable = true;
          withUWSM = true;
        };

        xdg.portal = {
          enable = true;
          xdgOpenUsePortal = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        };

        nix.settings = {
          substituters = [ "https://hyprland.cachix.org" ];
          trusted-substituters = [ "https://hyprland.cachix.org" ];
          trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
        };
      };

    hj =
      { config, ... }:
      {
        xdg.config.files =
          let
            cursorTheme = config.myLib.theming.cursorTheme.name;
            cursorSize = config.myLib.theming.cursorTheme.size;
          in
          {
            "hypr/hyprland.lua".source = ./hyprland.lua;
            "hypr/binds.lua".source = ./binds.lua;
            "hypr/config.lua".source = ./config.lua;
            "hypr/monitors.lua".source = ./monitors.lua;
            "hypr/rules.lua".source = ./rules.lua;

            "hypr/hyprland.conf".source = ./hyprland.conf;
            "uwsm/env".text = ''
              export GBM_BACKEND=nvidia-drm
              export __GLX_VENDOR_LIBRARY_NAME=nvidia
              export LIBVA_DRIVER_NAME=nvidia
              export QT_QPA_PLATFORM=wayland
              export QT_AUTO_SCREEN_SCALE_FACTOR=1
              export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
              export QT_QPA_PLATFORMTHEME=qt5ct
              export QT_QPA_PLATFORMTHEME_QT6=qt6ct
              export GDK_BACKEND=wayland,x11,*
              export NIXOS_OZONE_WL=1
              export XCURSOR_THEME=${cursorTheme}
              export XCURSOR_SIZE=${toString cursorSize}
            '';
            "uwsm/env-hyprland".text = ''
              export HYPRCURSOR_THEME=${cursorTheme}
              export HYPRCURSOR_SIZE=${toString cursorSize}
            '';
          };
      };
  };
}
