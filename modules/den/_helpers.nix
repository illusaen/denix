{ lib }:
let
  inherit (lib)
    mkOption
    nameValuePair
    optionalAttrs
    pipe
    types
    isAttrs
    isList
    unique
    ;
in
rec {
  mkSubmoduleOption =
    options:
    mkOption {
      type = types.submodule {
        inherit options;
      };
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

  cartesian =
    { left, right }:
    leftArray: rightArray:
    builtins.concatMap (
      leftItem:
      map (rightItem: {
        "${left}" = leftItem;
        "${right}" = rightItem;
      }) rightArray
    ) leftArray;

  mergeModule =
    lhs: rhs:
    if isAttrs lhs && isAttrs rhs then
      builtins.zipAttrsWith
        (
          _: values:
          if builtins.length values == 1 then
            builtins.head values
          else
            mergeModule (builtins.elemAt values 0) (builtins.elemAt values 1)
        )
        [
          lhs
          rhs
        ]
    else if isList lhs && isList rhs then
      unique (lhs ++ rhs)
    else
      rhs;
}
