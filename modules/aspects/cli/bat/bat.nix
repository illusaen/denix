{
  den,
  ...
}:
{
  den.aspects.cli._.bat = den.lib.perHost {
    os =
      { pkgs, config, ... }:
      let
        bat-theme = config.myLib.theming.colors {
          template = ./bat.tmTheme.mustache;
          extension = "tmTheme";
        };
        bat-wrapped = pkgs.symlinkJoin {
          name = "bat";
          paths = [ pkgs.bat ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out/themes
            install -Dm644 ${bat-theme} $out/themes/Base16-custom.tmTheme
            install -Dm644 ${./bat-config} $out/config
            wrapProgram $out/bin/bat --set BAT_CONFIG_DIR $out
          '';
        };
      in
      {
        environment.systemPackages = [ bat-wrapped ];
      };

    persistUser.directories = [ ".cache/bat" ];
  };
}
