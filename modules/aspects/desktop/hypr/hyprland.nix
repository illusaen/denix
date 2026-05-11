{ inputs, ... }:
{
  flake-file.inputs.hyprland.url = "github:hyprwm/Hyprland/af923e30d1d24f1f4a4f5cb8308065173c1d9539";

  den.aspects.desktop._.hyprland = {
    nixos =
      { pkgs, lib, ... }:
      {
        programs.hyprland = {
          enable = true;
          withUWSM = true;
          package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;
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

        environment.systemPackages = [
          (pkgs.writeShellScriptBin "hypr-toggle-fit" ''
            curr_val="$(hyprctl getoption scrolling:focus_fit_method -j | ${lib.getExe pkgs.jq} '. | .int')"
            if [[ $curr_val == 0 ]]; then
                val=1
                mode="fit"
            else
                val=0
                mode="center"
            fi
            hyprctl eval "hl.config" "{ scrolling = { focus_fit_method = $val } }"
            dms notify "Focus fit method: $mode"
          '')
        ];
      };

    hj =
      { pkgs, config, ... }:
      {
        xdg.config.files =
          let
            cursorTheme = config.myLib.theming.cursorTheme.name;
            cursorSize = config.myLib.theming.cursorTheme.size;
          in
          {
            "hypr/hyprland.lua".source = ./hyprland.lua;
            "hypr/binds.lua".source = ./binds.lua;
            "hypr/config.lua".source = pkgs.replaceVars ./config.lua {
              inherit (config.scheme) base00;
            };
            "hypr/monitors.lua".source = ./monitors.lua;
            "hypr/rules.lua".source = ./rules.lua;

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
