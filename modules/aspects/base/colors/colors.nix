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

  den.aspects.base.includes = with den.aspects.base; [ colors ];

  den.aspects.base.colors = {
    flake-config =
      {
        system,
        lib,
        ...
      }:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        base16Lib = inputs.base16.lib { inherit pkgs lib; };
        inherit (lib) mkOption types;

        mkThemingOptionType = types.submodule {
          options = {
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
        options.my.base16 = lib.mkOption {
          type = mkThemingOptionType;
        };
        options.my.scheme = mkOption {
          type = types.raw;
          readOnly = true;
        };
        config.my.base16.colorScheme = "dark";
        config.my.scheme = base16Lib.mkSchemeAttrs base16Scheme;
      };
  };
}
