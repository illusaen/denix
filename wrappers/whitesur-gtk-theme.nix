{
  wlib,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [wlib.modules.default];

  options = let
    inherit (lib) mkOption types;
  in {
    font = mkOption {type = types.str;};
    fontSize = mkOption {type = types.number;};
    altVariants = mkOption {
      type = types.listOf (
        types.enum [
          "normal"
          "alt"
          "all"
        ]
      );
      default = ["normal"];
    };
    colorVariants = mkOption {
      type = types.listOf (
        types.enum [
          "light"
          "dark"
        ]
      );
      default = [];
    };
    opacityVariants = mkOption {
      type = types.listOf (
        types.enum [
          "normal"
          "solid"
        ]
      );
      default = ["normal"];
    };
    themeVariants = mkOption {
      type = types.listOf (
        types.enum [
          "orange"
          "purple"
          "grey"
          "pink"
          "red"
          "yellow"
          "blue"
          "default"
        ]
      );
      default = [];
    };
    schemeVariants = mkOption {
      type = types.listOf (
        types.enum [
          "standard"
          "nord"
        ]
      );
      default = ["standard"];
    };
    nautilusStyle = mkOption {
      type = types.enum [
        "stable"
        "normal"
        "mojave"
        "glassy"
        "right"
      ];
      default = "glassy";
    };
    libadwaita = mkOption {
      type = types.bool;
      default = true;
    };
    hd = mkOption {
      type = types.bool;
      default = true;
    };
    roundedMaxWindow = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config.package = let
    rootFontSize = toString (config.fontSize + 3);
    subheadingSize = toString (config.fontSize + 5);
    baseFontSize = toString config.fontSize;
    titleFontSize = toString (config.fontSize + 1);
    captionFontSize = toString (config.fontSize - 2);
    replaceArgs = pairs: lib.escapeShellArgs (lib.concatMap (pair: ["--replace-fail"] ++ pair) pairs);
    variableReplacements = replaceArgs [
      [
        "$font-family: "
        "$font-family: ${config.font},"
      ]
      [
        "$large-font-family: "
        "$font-family: ${config.font},"
      ]
      [
        "$root-font-size: if($laptop == 'false', 15px, 13px);"
        "$root-font-size: ${rootFontSize}px;"
      ]
      [
        "$subheading-size: if($laptop == 'false', 17px, 15px);"
        "$subheading-size: ${subheadingSize}px;"
      ]
      [
        "$base_font_size: if($font_size == 'normal', 11pt, 10pt);"
        "$base_font_size: ${baseFontSize}pt;"
      ]
    ];
    gtkTextStyleReplacements = replaceArgs [
      [
        "font-size: 13pt;"
        "font-size: ${titleFontSize}pt;"
      ]
      [
        "font-size: 11pt;"
        "font-size: ${baseFontSize}pt;"
      ]
      [
        "font-size: 9pt;"
        "font-size: ${captionFontSize}pt;"
      ]
    ];
    installArgs =
      lib.concatMap (x: ["--alt" x]) config.altVariants
      ++ lib.concatMap (x: ["--color" x]) config.colorVariants
      ++ lib.concatMap (x: ["--opacity" x]) config.opacityVariants
      ++ lib.concatMap (x: ["--theme" x]) config.themeVariants
      ++ lib.concatMap (x: ["--scheme" x]) config.schemeVariants
      ++ lib.optionals (config.nautilusStyle != null) ["--nautilus" config.nautilusStyle]
      ++ lib.optional config.hd "--highdefinition"
      ++ lib.optional config.libadwaita "--libadwaita"
      ++ lib.optional config.roundedMaxWindow "--roundedmaxwindow";
  in
    pkgs.stdenv.mkDerivation {
      pname = "whitesur-gtk-theme";
      version = "master";

      src = pkgs.fetchFromGitHub {
        owner = "vinceliuice";
        repo = "whitesur-gtk-theme";
        rev = "a83f467e4c16b1ed1c960f3d89e2472d9639477c";
        hash = "sha256-zbYLek+OYizrtvV7zcaYENqZAuunNcg1gfFJ+3atuSc=";
      };

      nativeBuildInputs = with pkgs; [
        dialog
        glib
        jdupes
        libxml2
        sassc
        util-linux
      ];

      buildInputs = [
        pkgs.gnome-themes-extra # adwaita engine for Gtk2
      ];

      postPatch = ''
        find -name "*.sh" -print0 | while IFS= read -r -d ''' file; do
          patchShebangs "$file"
        done

        substituteInPlace libs/lib-core.sh \
          --replace-fail '$(which sudo)' false \
          --replace-fail 'MY_HOME=$(getent passwd "''${MY_USERNAME}" | cut -d: -f6)' 'MY_HOME=/tmp' \
          --replace-fail 'FIREFOX_THEME_DIR="''${FIREFOX_DIR_HOME}/firefox-themes"' 'FIREFOX_THEME_DIR="$out/share/firefox-themes"' \
          --replace-fail '  setterm -cursor off' '  return 0' \
          --replace-fail '  sleep 0.75; clear' '  sleep 0.75' \
          --replace-fail 'else
          GNOME_VERSION="48-0"
        fi' 'else
          SHELL_VERSION="48"
          GNOME_VERSION="48-0"
        fi'

        substituteInPlace libs/lib-install.sh \
          --replace-fail 'local TARGET_DIR="''${HOME}/.config/gtk-4.0"' 'local TARGET_DIR="$out/share/libadwaita-themes"' \
          --replace-fail '$'{HOME}'/.config/gtk-4.0' '$out/share/libadwaita-themes' \
          --replace-fail '  config_firefox' '  true'

        substituteInPlace tweaks.sh \
          --replace-fail 'if ! has_command firefox && ! has_command firefox-bin && ! has_flatpak_app org.mozilla.firefox && ! has_snap_app firefox && ! has_command firefox-developer-edition; then' 'if false; then' \
          --replace-fail 'elif [[ ! -d "''${FIREFOX_DIR_HOME}" && ! -d "''${FIREFOX_FLATPAK_DIR_HOME}" && ! -d "''${FIREFOX_SNAP_DIR_HOME}" ]]; then' 'elif false; then' \
          --replace-fail 'elif pidof "firefox" &> /dev/null || pidof "firefox-bin" &> /dev/null; then' 'elif false; then'

        substituteInPlace install.sh --replace-fail '$'{HOME}'/.config/gtk-4.0' '$out/share/libadwaita-themes'
        substituteInPlace src/sass/_variables.scss ${variableReplacements}
        substituteInPlace src/sass/gtk/_common-3.0.scss ${gtkTextStyleReplacements}
        substituteInPlace src/sass/gtk/_common-4.0.scss ${gtkTextStyleReplacements}
      '';

      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/themes

        ./install.sh ${lib.escapeShellArgs installArgs} --dest "$out/share/themes"

        ./tweaks.sh --firefox

        jdupes --quiet --link-soft --recurse $out/share

        runHook postInstall
      '';

      passthru.updateScript = pkgs.gitUpdater {};
    };
}
