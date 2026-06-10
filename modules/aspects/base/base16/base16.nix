{
  inputs,
  lib,
  den,
  ...
}:
let
  base16Scheme = ./cosmic.yaml;
  base16 = inputs.base16.lib {
    inherit lib;
    pkgs = null;
  };
  schemeAttrs = base16.mkSchemeAttrs base16Scheme;
in
{
  options.fleet.my.base16 = lib.mkOption {
    type = lib.types.submodule {
      options = {
        colorScheme = lib.mkOption {
          type = lib.types.enum [
            "dark"
            "light"
          ];
        };
        scheme = lib.mkOption {
          type = lib.types.raw;
          readOnly = true;
        };
      };
    };
  };

  config = {
    flake-file.inputs.base16.url = "github:SenchoPens/base16.nix";

    fleet.my = {
      base16 = {
        colorScheme = "dark";
        scheme = schemeAttrs // {
          render =
            {
              pkgs,
              lib,
              ...
            }@args:
            let
              renderBase16 = inputs.base16.lib { inherit lib pkgs; };
              renderScheme = renderBase16.mkSchemeAttrs base16Scheme;
            in
            renderScheme (
              removeAttrs args [
                "lib"
                "pkgs"
              ]
            );
        };
      };
    };
    flake.den = den;
  };
}
