{
  rootPath,
  ...
}:
{
  den.aspects.base.cli.bat = {
    wrapper-packages =
      { fleet, ... }:
      {
        bat = {
          imports = [ (rootPath + /wrappers/bat/bat.nix) ];
          renderScheme = fleet.my.base16.scheme.render;
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
