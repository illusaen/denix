{ den, ... }:
{
  den.aspects.cli._.gh = den.lib.perHost {
    os =
      { pkgs, ... }:
      let
        gh-wrapped = pkgs.symlinkJoin {
          name = "gh";
          paths = [
            pkgs.gh
          ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out
            install -Dm644 ${./gh-config.yaml} $out/config.yml
            wrapProgram $out/bin/gh --set GH_CONFIG_DIR $out
          '';
        };
      in
      {
        environment.systemPackages = [ gh-wrapped ];
      };
  };
}
