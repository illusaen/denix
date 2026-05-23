{
  den,
  ...
}:
{
  den.aspects.my = {
    flake-config =
      { myLib, ... }:
      {
        options.my = myLib.mkSubmoduleOption {
          vars = myLib.mkSubmoduleOption {
            userName = myLib.mkStrOption "wendy";
            accountName = myLib.mkStrOption "illusaen";
            displayName = myLib.mkStrOption "Wendy Chen";
            email = myLib.mkStrOption "jaewchen@gmail.com";
          };
        };
      };
  };

  den.default.includes = [ den.aspects.my ];
}
