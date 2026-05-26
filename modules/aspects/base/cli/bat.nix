{
  den,
  self,
  ...
}:
{
  den.aspects.base.cli.includes = with den.aspects.base.cli; [ bat ];

  den.aspects.base.cli.bat = {
    wrapper-packages.bat = {
      imports = [ ../../../../wrappers/bat/bat.nix ];
      renderScheme = self.my.scheme.render;
    };

    os =
      { self', ... }:
      {
        environment.systemPackages = [ self'.packages.bat ];
      };

    provides.to-users.persistUser.directories = [ ".cache/bat" ];
  };
}
