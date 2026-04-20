{ den, ... }:
{
  den.ctx.user.includes = [ den.aspects.cli._.fd ];
  den.aspects.cli._.fd = {
    os =
      { pkgs, ... }:
      let
        fd-wrapped = pkgs.symlinkJoin {
          name = "fd";
          paths = [ pkgs.fd ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out
            wrapProgram $out/bin/fd --add-flag --hidden --add-flag --follow
          '';
        };
      in
      {
        environment.systemPackages = [ fd-wrapped ];
      };

    hjem = {
      files.".config/fd/ignore".text = ''
        .git
        /etc/static
        /etc/systemd
        /etc/terminfo
        /etc/tmpfiles.d
        /etc/udev
      '';
    };
  };
}
