{
  den,
  lib,
  ...
}:
{
  den.aspects.cli._.eza = den.lib.perHost {
    os =
      { config, pkgs, ... }:
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
        programs.fish = lib.mkIf config.programs.fish.enable {
          shellAliases = {
            l = "eza -alg";
            ll = "eza --tree --git-ignore --all";
          };
        };
      };
  };
}
