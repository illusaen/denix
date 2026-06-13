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
  altVariants ? [ "normal" ], # default: normal
  colorVariants ? [ "dark" ], # default: all
  opacityVariants ? [ "normal" ], # default: all
  themeVariants ? [ "pink" ], # default: default (BigSur-like theme)
  schemeVariants ? [ "standard" ], # default: standard # default: standard (Apple logo)
  nautilusStyle ? "stable", # default: stable (BigSur-like style)
  font ? "Inter",
}:
stdenv.mkDerivation rec {
  pname = "whitesur-gtk-theme";
  version = "2025-07-24";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "whitesur-gtk-theme";
    rev = version;
    hash = "sha256-tuon9XxMdrz9XNTp50sbss2gtx6H9hEZh8t2jSoqx28=";
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

    # Do not provide `sudo`, as it is not needed in our use case of the install script
    substituteInPlace libs/lib-core.sh --replace-fail '$(which sudo)' false

    # Provides a dummy home directory
    substituteInPlace libs/lib-core.sh --replace-fail 'MY_HOME=$(getent passwd "''${MY_USERNAME}" | cut -d: -f6)' 'MY_HOME=/tmp'

    substituteInPlace src/sass/_variables.scss --replace-fail '$font-family: ' '$font-family: ${font},' 
    substituteInPlace src/sass/_variables.scss --replace-fail '$large-font-family: ' '$font-family: ${font},' 
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes

    ./install.sh \
      ${toString (map (x: "--alt " + x) altVariants)} \
      ${toString (map (x: "--color " + x) colorVariants)} \
      ${toString (map (x: "--opacity " + x) opacityVariants)} \
      ${toString (map (x: "--theme " + x) themeVariants)} \
      ${toString (map (x: "--scheme " + x) schemeVariants)} \
      ${lib.optionalString (nautilusStyle != null) ("--nautilus " + nautilusStyle)} \
      --libadwaita \
      --highdefinition \
      --roundedmaxwindow \
      --dest $out/share/themes

    firefoxTheme=$out/share/firefox-theme
    mkdir -p "$firefoxTheme/WhiteSur/parts"
    cp src/other/firefox/customChrome.css "$firefoxTheme"
    cp -r src/other/firefox/WhiteSur/. "$firefoxTheme/WhiteSur"
    cp -r src/other/firefox/common/icons src/other/firefox/common/pages "$firefoxTheme/WhiteSur"
    cp -r src/other/firefox/common/titlebuttons "$firefoxTheme/WhiteSur/titlebuttons"
    cp src/other/firefox/common/*.css "$firefoxTheme/WhiteSur"
    cp src/other/firefox/common/parts/*.css "$firefoxTheme/WhiteSur/parts"
    cp src/other/firefox/userChrome-WhiteSur.css "$firefoxTheme/userChrome.css"
    cp src/other/firefox/userContent-WhiteSur.css "$firefoxTheme/userContent.css"

    jdupes --quiet --link-soft --recurse $out/share

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { };
}
