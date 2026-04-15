{
  den,
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs.niri = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.desktop.includes = [ den.aspects.niri ];

  den.aspects.niri = {
    includes = lib.attrValues den.aspects.niri._;

    _.enable = den.lib.perHost {
      nixos =
        { pkgs, lib, ... }:
        {
          imports = [ inputs.niri.nixosModules.niri ];
          nix.settings.extra-substituters = [ "https://niri.cachix.org" ];
          nix.settings.extra-trusted-public-keys = [
            "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
          ];

          nixpkgs.overlays = [ inputs.niri.overlays.niri ];
          programs.niri.enable = true;
          programs.niri.package = pkgs.niri-stable;
          systemd.user.services.niri-flake-polkit.enable = lib.mkDefault false;
          services.displayManager.defaultSession = "niri";
        };
    };

    _.config = den.lib.perHost {
      hm =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        let
          # Custom script to startup certain apps after a delay
          # to allow for the system tray to load first
          delayedStartup = pkgs.writeShellScript "delayed-startup" ''
            # syntax: bash
            ${pkgs.coreutils}/bin/sleep 1
            for file in ${config.xdg.configHome}/autostart/*.desktop; do
              if ${pkgs.gnugrep}/bin/grep -q "NotShowIn=.*niri" "$file"; then
                ${pkgs.dex}/bin/dex "$file"
              fi
            done
          '';
        in
        {
          programs.niri = {
            package = lib.mkDefault pkgs.niri;

            settings = {
              xwayland-satellite = {
                enable = lib.mkDefault true;
                path = lib.mkDefault "${lib.getExe pkgs.xwayland-satellite}";
              };

              spawn-at-startup = [
                { command = [ "${delayedStartup}" ]; }
                { command = [ "${lib.getExe config.programs.noctalia-shell.package}" ]; }
              ];
            };
          };

          xdg.portal.config.niri = {
            default = lib.mkDefault [
              "gnome"
              "gtk"
            ];
            "org.freedesktop.impl.portal.ScreenCast" = lib.mkDefault [ "gnome" ];
            "org.freedesktop.impl.portal.Screenshot" = lib.mkDefault [ "gnome" ];
            "org.freedesktop.impl.portal.FileChooser" = lib.mkDefault [ "gtk" ];
          };
        };
    };
  };
}
