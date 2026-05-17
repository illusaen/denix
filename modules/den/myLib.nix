{
  den,
  helpers,
  ...
}:
let
  inherit (helpers) mkSubmoduleOption;
in
{
  den.aspects.my = {
    flake-config = {
      options.my = mkSubmoduleOption { };
    };
  };

  den.default.includes = [ den.aspects.my ];
}
