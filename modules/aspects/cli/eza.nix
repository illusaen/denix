{
  den,
  ...
}:
{
  den.aspects.cli._.eza = den.lib.perHost {
    fish.shellAliases = {
      l = "eza -alg";
      ll = "eza --tree --git-ignore --all";
    };

    os =
      { pkgs, ... }:
      let
        eza-wrapped = pkgs.symlinkJoin {
          name = "eza";
          paths = [ pkgs.eza ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out
            wrapProgram $out/bin/eza --add-flag --icons --add-flag auto --add-flag --git
          '';
        };
      in
      {
        environment.systemPackages = [ eza-wrapped ];
      };
  };
}
