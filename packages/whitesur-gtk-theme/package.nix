{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  dialog,
  glib,
  gnome-themes-extra,
  jdupes,
  libxml2,
  sassc,
  util-linux,
  font ? "Inter",
  fontSize ? 12,
  altVariants ? [],
  colorVariants ? [],
  opacityVariants ? [],
  themeVariants ? [],
  schemeVariants ? [],
  nautilusStyle ? null,
  installLibadwaita ? false,
  hd ? false,
  roundedMaxWindow ? false,
  ...
}: let
  rootFontSize = toString (builtins.floor (fontSize * 4 / 3 + 0.5));
  subheadingSize = toString (fontSize + 3);
  baseFontSize = toString fontSize;
  titleFontSize = toString (fontSize + 1);
  captionFontSize = toString (fontSize - 2);
  replaceArgs = pairs: lib.escapeShellArgs (lib.concatMap (pair: ["--replace-fail"] ++ pair) pairs);
  variableReplacements = replaceArgs [
    [
      "$font-family: "
      "$font-family: ${font},"
    ]
    [
      "$large-font-family: "
      "$large-font-family: ${font},"
    ]
    [
      "$root-font-size: if($laptop == 'false', 15px, 13px);"
      "$root-font-size: ${rootFontSize}px;"
    ]
    [
      "$subheading-size: if($laptop == 'false', 17px, 15px);"
      "$subheading-size: ${subheadingSize}pt;"
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
  gtkDarkBorderReplacements = replaceArgs [
    [
      "$borders_color:                     if($variant == 'light', rgba(black, 0.12), rgba(white, 0.12));"
      "$borders_color:                     if($variant == 'light', rgba(black, 0.5), rgba(white, 0.5));"
    ]
  ];
  libadwaitaDarkBorderReplacements = replaceArgs [
    [
      "$borders_color:                     gtkalpha(currentColor, 0.12);"
      "$borders_color:                     gtkalpha(currentColor, 0.5);"
    ]
  ];
  installArgs =
    lib.concatMap (x: ["--alt" x]) altVariants
    ++ lib.concatMap (x: ["--color" x]) colorVariants
    ++ lib.concatMap (x: ["--opacity" x]) opacityVariants
    ++ lib.concatMap (x: ["--theme" x]) themeVariants
    ++ lib.concatMap (x: ["--scheme" x]) schemeVariants
    ++ lib.optionals (nautilusStyle != null) ["--nautilus" nautilusStyle]
    ++ lib.optional hd "--highdefinition"
    ++ lib.optional installLibadwaita "--libadwaita"
    ++ lib.optional roundedMaxWindow "--roundedmaxwindow";
in
  stdenv.mkDerivation {
    pname = "whitesur-gtk-theme";
    version = "master";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "whitesur-gtk-theme";
      rev = "a83f467e4c16b1ed1c960f3d89e2472d9639477c";
      hash = "sha256-zbYLek+OYizrtvV7zcaYENqZAuunNcg1gfFJ+3atuSc=";
    };

    nativeBuildInputs = [
      dialog
      glib
      jdupes
      libxml2
      sassc
      util-linux
    ];

    buildInputs = [
      gnome-themes-extra # adwaita engine for Gtk2
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
      substituteInPlace src/sass/_colors.scss ${gtkDarkBorderReplacements}
      substituteInPlace src/sass/gtk/_colors-libadwaita.scss ${libadwaitaDarkBorderReplacements}
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

    passthru.updateScript = gitUpdater {};
  }
