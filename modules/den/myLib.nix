{
  den,
  helpers,
  ...
}:
let
  inherit (helpers) mkSubmoduleOption;
in
{
  den.aspects.myLib = {
    os = {
      options.myLib = mkSubmoduleOption { };
    };
  };

  den.default.includes = [ den.aspects.myLib ];
}
