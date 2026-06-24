{
  inputs,
  lib,
  ...
}: let
  base16Scheme = ./tokyo-night-moon.yaml;
  base16 = inputs.base16.lib {
    inherit lib;
    pkgs = null;
  };
  schemeAttrs = base16.mkSchemeAttrs base16Scheme;
in {
  config = {
    flake-file.inputs.base16.url = "github:SenchoPens/base16.nix";

    den.aspects.base.base16.settings = {
      colorScheme = lib.mkOption {
        type = lib.types.enum [
          "dark"
          "light"
        ];
        default = "dark";
      };
      scheme = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        default =
          schemeAttrs
          // {
            render = {
              pkgs,
              lib,
              ...
            } @ args: let
              renderBase16 = inputs.base16.lib {inherit lib pkgs;};
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
  };
}
