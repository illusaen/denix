{ den, ... }:
{
  den.aspects.base.cli.includes = with den.aspects.base.cli; [ eza ];

  den.aspects.base.cli.eza = {
    shell.shellAliases = {
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
