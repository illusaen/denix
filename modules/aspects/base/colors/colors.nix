{
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

  den.aspects.base.colors = {
    os =
      {
        lib,
        ...
      }:
      let
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

        imports = [ inputs.base16.nixosModule ];

        config = {
          scheme = base16Scheme;
          my.base16.colorScheme = "dark";
        };
      };
  };
}
