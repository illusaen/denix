{ lib }:
let
  inherit (lib)
    mkOption
    nameValuePair
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

  mapListToAttrsWith =
    attrs: value:
    pipe attrs [
      (map (v: nameValuePair v value))
      builtins.listToAttrs
    ];
}
