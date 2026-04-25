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

  den.aspects.desktop._.theming = den.lib.perHost {
    nixos =
      {
        pkgs,
        config,
        lib,
        helpers,
        ...
      }:
      let
        inherit (lib) mkOption types;
        cfg = config.myLib.theming;
        inherit (helpers) mkThemeType;

        mkThemingOptionType = types.submodule {
          options = {
            colors = mkOption {
              type = types.anything;
            };
            base16Scheme = mkOption {
              type = types.path;
            };
            schemeName = mkOption {
              type = types.str;
            };
            iconTheme = mkOption {
              type = mkThemeType { };
            };
            cursorTheme = mkOption {
              type = mkThemeType { hasSize = true; };
            };
            colorScheme = mkOption {
              type = types.enum [
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
