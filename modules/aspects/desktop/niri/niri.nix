{
  den,
  ...
}:
{
  den.aspects.desktop._.niri = den.lib.perHost {
    nixos =
      { pkgs, ... }:

      {
        nix.settings.extra-substituters = [ "https://niri.cachix.org" ];
        nix.settings.extra-trusted-public-keys = [
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        ];

        programs.niri.enable = true;

        systemd.user.services = {
          delayed-startup = {
            wantedBy = [ "graphical-session.target" ];
            description = "Delayed startup of programs in xdg autostart that have NotShowIn=niri attr";
            script = ''
              ${pkgs.coreutils}/bin/sleep 1
              for file in $HOME/.config/autostart/*.desktop; do
                if ${pkgs.gnugrep}/bin/grep -q "NotShowIn=.*niri" "$file"; then
                  echo "Starting $file"
                  ${pkgs.dex}/bin/dex "$file"
                fi
              done
            '';
          };
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
      };

    hj =
      { pkgs, osConfig, ... }:
      {
        xdg.config.files."niri/config.kdl".source = pkgs.replaceVars ./config.kdl {
          cursorTheme = "\"${osConfig.myLib.theming.cursorTheme.name}\"";
          cursorSize = osConfig.myLib.theming.cursorTheme.size;
        };
      };
  };
}
