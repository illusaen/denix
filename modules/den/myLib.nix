{ den, lib, ... }:
let
  helpers = import ./_helpers.nix { inherit lib; };
in
{
  den.aspects.myLib = {
    os = {
      options.myLib = helpers.mkSubmoduleOption { };
      config._module.args = { inherit helpers; };
    };

    hjem.config._module.args = { inherit helpers; };
  };

  den.default.includes = [ den.aspects.myLib ];
}
