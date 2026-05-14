{ den, ... }:
{
  den.aspects.base.cli.includes = with den.aspects.base.cli; [ fd ];

  den.aspects.base.cli.fd = {
    os =
      { pkgs, ... }:
      let
        fd-wrapped = pkgs.symlinkJoin {
          name = "fd";
          paths = [ pkgs.fd ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out
            wrapProgram $out/bin/fd --add-flag --hidden --add-flag --follow --add-flag --exclude --add-flag .git
          '';
        };
      in
      {
        environment.systemPackages = [ fd-wrapped ];
      };
  };
}
