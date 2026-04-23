{
  den,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    base16.url = "github:SenchoPens/base16.nix";
    tt-schemes = {
      url = "github:tinted-theming/schemes/spec-0.11";
      flake = false;
    };
  };

  den.aspects.desktop.includes = [ den.aspects.theming ];
  den.aspects.theming = {
    nixos =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      let
        cfg = config.myLib.theming;

        mkThemeType =
          {
            hasSize ? false,
          }:
          lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
              };
              package = lib.mkOption {
                type = lib.types.package;
              };
            }
            // lib.optionalAttrs hasSize {
              size = lib.mkOption { type = lib.types.int; };
            };
          };
        mkThemingOptionType = lib.types.submodule {
          options = {
            colors = lib.mkOption {
              type = lib.types.anything;
            };
            base16Scheme = lib.mkOption {
              type = lib.types.path;
            };
            schemeName = lib.mkOption {
              type = lib.types.str;
            };
            iconTheme = lib.mkOption {
              type = mkThemeType { };
            };
            cursorTheme = lib.mkOption {
              type = mkThemeType { hasSize = true; };
            };
            colorScheme = lib.mkOption {
              type = lib.types.enum [
                "dark"
                "light"
              ];
            };
          };
        };
      in
      {
        options.myLib.theming = lib.mkOption {
          type = mkThemingOptionType;
        };

        imports = [ inputs.base16.nixosModule ];

        config = {
          myLib.theming = {
            colors = config.lib.base16.mkSchemeAttrs cfg.base16Scheme;
            base16Scheme = "${inputs.tt-schemes}/base24/${cfg.schemeName}.yaml";
            schemeName = "chalk";
            iconTheme = {
              name = "Dracula";
              package = pkgs.dracula-icon-theme;
            };
            cursorTheme = {
              name = "Nordic-cursors";
              package = pkgs.nordic;
              size = 28;
            };
            colorScheme = "dark";
          };

          environment.systemPackages = with pkgs; [
            adw-gtk3
            adwaita-qt6
            dracula-icon-theme
            nordic
          ];
        };
      };
  };
}
