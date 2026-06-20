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
      { pkgs, lib, ... }:
      {
        environment.systemPackages = [ pkgs.local.bat ];
        environment.shellAliases = {
          cat = "bat";
        };

        system.activationScripts.rebuildBatCache = ''
          echo "Rebuilding bat cache."
          ${lib.getExe pkgs.local.bat} cache --build
        '';
      };
  };
}
