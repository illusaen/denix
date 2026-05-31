{
  den,
  rootPath,
  ...
}:
{
  den.aspects.base.cli.includes = with den.aspects.base.cli; [ bat ];

  den.aspects.base.cli.bat = {
    wrapper-packages =
      { fleet, ... }:
      {
        bat = {
          imports = [ (rootPath + /wrappers/bat/bat.nix) ];
          renderScheme = fleet.my.scheme.render;
        };
      };

    os =
      { self', ... }:
      {
        environment.systemPackages = [ self'.packages.bat ];
        environment.shellAliases = {
          cat = "bat";
        };
      };

    provides.to-users.persistUser.directories = [ ".cache/bat" ];
  };
}
