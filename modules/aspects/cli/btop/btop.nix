{
  den,
  ...
}:
{
  den.aspects.cli._.btop = den.lib.perHost {
    os =
      { pkgs, ... }:
      let
        btop-wrapped = pkgs.symlinkJoin {
          name = "btop";
          paths = [ pkgs.btop ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out/share/themes
            install -Dm644 ${./btop.theme} $out/share/themes/custom.theme
            echo "color_theme = \"custom\"" > $out/btop.conf
            wrapProgram $out/bin/btop --add-flag --config --add-flag $out/btop.conf --add-flag --themes-dir --add-flag $out/share/themes
          '';
        };
      in
      {
        environment.systemPackages = [ btop-wrapped ];
      };
  };
}
