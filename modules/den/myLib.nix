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
    os = {
      options.my = mkSubmoduleOption { };
    };
  };

  den.default.includes = [ den.aspects.my ];
}
