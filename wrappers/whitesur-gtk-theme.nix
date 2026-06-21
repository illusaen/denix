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

  config.package = pkgs.stdenv.mkDerivation {
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

            # Do not provide `sudo`, as it is not needed in our use case of the install script
            substituteInPlace libs/lib-core.sh --replace-fail '$(which sudo)' false

            # Provides a dummy home directory
            substituteInPlace libs/lib-core.sh --replace-fail 'MY_HOME=$(getent passwd "''${MY_USERNAME}" | cut -d: -f6)' 'MY_HOME=/tmp'

            # Upstream only sets GNOME_VERSION in this fallback, but shell_base also needs SHELL_VERSION.
            substituteInPlace libs/lib-core.sh --replace-fail 'else
        GNOME_VERSION="48-0"
      fi' 'else
        SHELL_VERSION="48"
        GNOME_VERSION="48-0"
      fi'

            substituteInPlace src/sass/_variables.scss --replace-fail '$font-family: ' '$font-family: ${config.font},'
            substituteInPlace src/sass/_variables.scss --replace-fail '$large-font-family: ' '$font-family: ${config.font},'

            # Installs libadwaita to out/share/libadwaita-themes
            substituteInPlace libs/lib-install.sh --replace-fail 'local TARGET_DIR="''${HOME}/.config/gtk-4.0"' 'local TARGET_DIR="$out/share/libadwaita-themes"'
            substituteInPlace libs/lib-install.sh --replace-fail '$'{HOME}'/.config/gtk-4.0' '$out/share/libadwaita-themes'
            substituteInPlace install.sh --replace-fail '$'{HOME}'/.config/gtk-4.0' '$out/share/libadwaita-themes'

            # Avoid terminal spinner control in the non-interactive Nix build log.
            substituteInPlace libs/lib-core.sh \
              --replace-fail '  setterm -cursor off' '  return 0'
            substituteInPlace libs/lib-core.sh --replace-fail '  sleep 0.75; clear' '  sleep 0.75'

            # Installs firefox themes to out/share/firefox-themes
            substituteInPlace libs/lib-core.sh --replace-fail 'FIREFOX_THEME_DIR="''${FIREFOX_DIR_HOME}/firefox-themes"' 'FIREFOX_THEME_DIR="$out/share/firefox-themes"'
            substituteInPlace libs/lib-install.sh --replace-fail '  config_firefox' '  true'
            substituteInPlace tweaks.sh \
              --replace-fail 'if ! has_command firefox && ! has_command firefox-bin && ! has_flatpak_app org.mozilla.firefox && ! has_snap_app firefox && ! has_command firefox-developer-edition; then' 'if false; then'
            substituteInPlace tweaks.sh \
              --replace-fail 'elif [[ ! -d "''${FIREFOX_DIR_HOME}" && ! -d "''${FIREFOX_FLATPAK_DIR_HOME}" && ! -d "''${FIREFOX_SNAP_DIR_HOME}" ]]; then' 'elif false; then'
            substituteInPlace tweaks.sh \
              --replace-fail 'elif pidof "firefox" &> /dev/null || pidof "firefox-bin" &> /dev/null; then' 'elif false; then'
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
        ${lib.optionalString (config.hd == true) "--highdefinition "} \
        ${lib.optionalString (config.libadwaita == true) "--libadwaita "} \
        ${lib.optionalString (config.roundedMaxWindow == true) "--roundedmaxwindow "} \
        --dest $out/share/themes

      ./tweaks.sh --firefox

      jdupes --quiet --link-soft --recurse $out/share

      runHook postInstall
    '';

    passthru.updateScript = pkgs.gitUpdater {};
  };
}
