{
  den,
  ...
}:
{
  den.aspects.cli._.bat = den.lib.perHost {
    os =
      { pkgs, ... }:
      let
        bat-wrapped = pkgs.symlinkJoin {
          name = "bat";
          paths = [ pkgs.bat ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out/themes
            install -Dm644 ${./bat.tmTheme} $out/themes/Base16-custom.theme
            install -Dm644 ${./bat-config} $out/bat.conf
            wrapProgram $out/bin/bat --set BAT_CONFIG_DIR $out
          '';
        };
      in
      {
        environment.systemPackages = [ bat-wrapped ];
      };
  };
}
