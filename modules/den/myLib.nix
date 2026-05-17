{
  den,
  ...
}:
{
  den.aspects.my = {
    flake-config =
      { myLib, ... }:
      {
        options.my = myLib.mkSubmoduleOption { };
      };
  };

  den.default.includes = [ den.aspects.my ];
}
