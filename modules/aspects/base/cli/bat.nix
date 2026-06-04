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
      { self', lib, ... }:
      {
        environment.systemPackages = [ self'.packages.bat ];
        environment.shellAliases = {
          cat = "bat";
        };

        system.activationScripts.rebuildBatCache = ''
          echo "Rebuilding bat cache."
          ${lib.getExe self'.packages.bat} cache --build
        '';
      };

    provides.to-users.persistUser.directories = [ ".cache/bat" ];
  };
}
