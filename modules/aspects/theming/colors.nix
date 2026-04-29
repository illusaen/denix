{
  den,
  inputs,
  ...
}:
let
  base16Scheme = ./cosmic.yaml;
in
{
  flake-file.inputs = {
    base16.url = "github:SenchoPens/base16.nix";
  };

  den.ctx.host.includes = [ den.aspects.colors ];
  den.aspects.colors = {
    os =
      {
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
            inherit base16Scheme;
            colorScheme = "dark";
          };
        };
      };
  };
}
