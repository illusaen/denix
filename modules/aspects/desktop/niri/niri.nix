{
  den,
  ...
}:
{
  den.aspects.desktop.includes = [ den.aspects.niri ];

  den.aspects.niri = {
    nixos =
      { pkgs, lib, ... }:
      {
        nix.settings.extra-substituters = [ "https://niri.cachix.org" ];
        nix.settings.extra-trusted-public-keys = [
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        ];

        programs.niri.enable = true;

        systemd.user.services.niri-flake-polkit.enable = lib.mkDefault false;
        services.displayManager.defaultSession = "niri";

        environment.systemPackages = with pkgs; [
          xdg-desktop-portal
          xwayland-satellite
        ];
      };

    md =
      {
        pkgs,
        lib,
        ...
      }:
      let
        kdlConfig = pkgs.writeText "niri-config-kdl" (
          builtins.readFile ./config.kdl
          + ''
            spawn-at-startup "sh" "-c" "noctalia-shell"
            xwayland-satellite { path "${lib.getExe pkgs.xwayland-satellite}"; }
          ''
        );
      in
      {
        systemd.services.delayed-startup = {
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          requires = [ "graphical-session-pre.target" ];
          after = [
            "graphical-session.target"
            "graphical-session-pre.target"
          ];
          description = "Delayed startup of programs in xdg autostart that have NotShowIn=niri attr";
          script = ''
            ${pkgs.coreutils}/bin/sleep 1
            for file in $HOME/.config/autostart/*.desktop; do
              if ${pkgs.gnugrep}/bin/grep -q "NotShowIn=.*niri" "$file"; then
                ${pkgs.dex}/bin/dex "$file"
              fi
            done
          '';
        };

        file.xdg_config."niri/config.kdl".source = kdlConfig;
        file.xdg_config."xdg-desktop-portal/niri-portals.conf".text = lib.generators.toINI { } {
          preferred = {
            default = "gnome";
            "org.freedesktop.impl.portal.ScreenCast" = "gnome";
            "org.freedesktop.impl.portal.Screenshot" = "gnome";
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
          };
        };
      };
  };
}
