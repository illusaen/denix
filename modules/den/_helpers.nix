{ lib }:
let
  inherit (lib)
    mkOption
    nameValuePair
    optionalAttrs
    pipe
    types
    ;
in
{
  mkSubmoduleOption =
    options:
    mkOption {
      type = types.submodule {
        inherit options;
      };
    };

  mkStrOption =
    default:
    mkOption {
      type = types.str;
      inherit default;
    };

  mkThemeType =
    {
      hasSize ? false,
    }:
    types.submodule {
      options = {
        name = mkOption {
          type = types.str;
        };
        package = mkOption {
          type = types.package;
        };
      }
      // optionalAttrs hasSize {
        size = mkOption { type = types.int; };
      };
    };

  mapListToAttrsWith =
    attrs: value:
    pipe attrs [
      (map (v: nameValuePair v value))
      builtins.listToAttrs
    ];
}
