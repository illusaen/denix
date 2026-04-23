{ den, lib, ... }:
let
  inherit (lib)
    mkOption
    nameValuePair
    optionalAttrs
    pipe
    types
    ;

  helpers = {
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
  };
in
{
  den.aspects.myLib = {
    includes = lib.attrValues den.aspects.myLib._;

    _.hostConfig = den.lib.perHost {
      os = {
        options.myLib = helpers.mkSubmoduleOption { };

        config._module.args = { inherit helpers; };
      };
    };

    _.userConfig = den.lib.perUser {
      hjem.config._module.args = { inherit helpers; };
    };

  };

  den.default.includes = [ den.aspects.myLib ];
}
