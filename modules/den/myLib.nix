{
  den,
  helpers,
  ...
}:
{
  den.aspects.myLib = {
    os = {
      options.myLib = helpers.mkSubmoduleOption { };
    };
  };

  den.default.includes = [ den.aspects.myLib ];
}
