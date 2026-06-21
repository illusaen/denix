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
      default = ["orange"];
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

  config.package = pkgs.stdenv.mkDerivation rec {
    pname = "whitesur-gtk-theme";
    version = "2025-07-24";

    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "whitesur-gtk-theme";
      rev = version;
      hash = "sha256-tuon9XxMdrz9XNTp50sbss2gtx6H9hEZh8t2jSoqx28=";
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

      # Do not provide `sudo`, as it is not needed in our use case of the install script
      substituteInPlace libs/lib-core.sh --replace-fail '$(which sudo)' false

      # Provides a dummy home directory
      substituteInPlace libs/lib-core.sh --replace-fail 'MY_HOME=$(getent passwd "''${MY_USERNAME}" | cut -d: -f6)' 'MY_HOME=/tmp'

      substituteInPlace src/sass/_variables.scss --replace-fail '$font-family: ' '$font-family: ${config.font},'
      substituteInPlace src/sass/_variables.scss --replace-fail '$large-font-family: ' '$font-family: ${config.font},'
    '';

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/themes

      ./install.sh \
        ${toString (map (x: "--alt " + x) config.altVariants)} \
        ${toString (map (x: "--color " + x) config.colorVariants)} \
        ${toString (map (x: "--opacity " + x) config.opacityVariants)} \
        ${toString (map (x: "--theme " + x) config.themeVariants)} \
        ${toString (map (x: "--scheme " + x) config.schemeVariants)} \
        ${lib.optionalString (config.nautilusStyle != null) ("--nautilus " + config.nautilusStyle)} \
        ${lib.optionalString (config.libadwaita == true) "--libadwaita "} \
        ${lib.optionalString (config.hd == true) "--highdefinition "} \
        ${lib.optionalString (config.roundedMaxWindow == true) "--roundedmaxwindow "} \
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

    passthru.updateScript = pkgs.gitUpdater {};
  };
}
