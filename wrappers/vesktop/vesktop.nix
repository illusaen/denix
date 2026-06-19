{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:
{
  imports = [
    wlib.modules.default
    ../service.nix
  ];

  options = {
    instanceName = lib.mkOption {
      type = lib.types.addCheck lib.types.str (value: builtins.match "[A-Za-z0-9._-]+" value != null);
      default = "default";
      description = "Name used to isolate this Vesktop instance's writable data.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "\${XDG_DATA_HOME:-$HOME/.local/share}/vesktop/${config.instanceName}";
      description = "Runtime-writable Vesktop user data directory. Environment variables are expanded.";
    };

    sharedConfigDir = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "/etc/packages/vesktop/${config.instanceName}";
      description = "Optional root-provisioned shared config directory used to seed each user's writable data.";
    };

    displayName = lib.mkOption {
      type = lib.types.str;
      default = "Vesktop (${config.instanceName})";
      description = "Name shown in the desktop application launcher.";
    };

    fonts = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
    };

    colors = lib.mkOption { type = lib.types.raw; };

    settings =
      let
        jsonFormat = pkgs.formats.json { };
      in
      {
        vesktop = lib.mkOption {
          inherit (jsonFormat) type;
          default = { };
        };
        vencord = lib.mkOption {
          inherit (jsonFormat) type;
          default = { };
        };
        quickCss = lib.mkOption {
          type = lib.types.lines;
          default = "";
        };
        themes = lib.mkOption {
          type = lib.types.attrsOf (lib.types.either lib.types.path lib.types.lines);
          default = { };
          description = "Theme file names mapped to CSS contents or paths.";
        };
      };
  };

  config = {
    package = lib.mkDefault pkgs.vesktop;
    binName = lib.mkDefault "vesktop-${config.instanceName}";
    filesToExclude = [ "share/applications/vesktop.desktop" ];
    service = {
      enable = true;
      serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
    };

    settings.vencord = {
      autoUpdate = false;
      autoUpdateNotification = false;
      useQuickCss = true;
      transparent = true;
      plugins = {
        ClearURLs.enabled = true;
        FixYoutubeEmbeds.enabled = true;
        FakeNitro.enabled = true;
      };
      enabledThemes = [ "base16.css" ];
    };
    settings.quickCss = ''
      :root {
          --font: "${config.fonts.sans}";
          --font-code: "${config.fonts.mono}";
          --base00: ${config.colors.base00};
          --base01: ${config.colors.base01};
          --base02: ${config.colors.base02};
          --base03: ${config.colors.base03};
          --base04: ${config.colors.base04};
          --base05: ${config.colors.base05};
          --base06: ${config.colors.base06};
          --base07: ${config.colors.base07};
          --base08: ${config.colors.base08};
          --base09: ${config.colors.base09};
          --base0A: ${config.colors.base0A};
          --base0B: ${config.colors.base0B};
          --base0C: ${config.colors.base0C};
          --base0D: ${config.colors.base0D};
          --base0E: ${config.colors.base0E};
          --base0F: ${config.colors.base0F};
      }
    '';
    settings.themes = {
      "base16.css" = ./base16.css;
    };
  };

  config.constructFiles = {
    vesktopSettings = {
      content = builtins.toJSON config.settings.vesktop;
      relPath = "defaults/settings.json";
    };
    vencordSettings = {
      content = builtins.toJSON config.settings.vencord;
      relPath = "defaults/settings/settings.json";
    };
    quickCss = {
      content = config.settings.quickCss;
      relPath = "defaults/settings/quickCss.css";
    };
    desktopEntry = {
      content = ''
        [Desktop Entry]
        Name=${config.displayName}
        GenericName=Internet Messenger
        Exec=${placeholder "out"}/bin/${config.binName} %U
        Icon=vesktop
        StartupWMClass=Vesktop
        Type=Application
        Categories=Network;InstantMessaging;Chat;
        Keywords=discord;vencord;chat;
      '';
      relPath = "share/applications/${config.binName}.desktop";
    };
  }
  // (lib.mapAttrs' (
    name: value:
    lib.nameValuePair "theme-${name}" {
      content = if builtins.isPath value then builtins.readFile value else value;
      relPath = "defaults/themes/${name}";
    }
  ) config.settings.themes);

  config.runShell =
    let
      managedFiles = [
        {
          source = config.constructFiles.vesktopSettings.path;
          target = "settings.json";
        }
        {
          source = config.constructFiles.vencordSettings.path;
          target = "settings/settings.json";
        }
        {
          source = config.constructFiles.quickCss.path;
          target = "settings/quickCss.css";
        }
      ]
      ++ lib.mapAttrsToList (name: _: {
        source = config.constructFiles."theme-${name}".path;
        target = "themes/${name}";
      }) config.settings.themes;
    in
    [
      ''
        export VENCORD_USER_DATA_DIR=${wlib.escapeShellArgWithEnv config.dataDir}
        shared_config_dir=${wlib.escapeShellArgWithEnv (config.sharedConfigDir or "")}
        ${pkgs.coreutils}/bin/mkdir -p "$VENCORD_USER_DATA_DIR"

        ${lib.concatMapStringsSep "\n" (
          file:
          let
            target = "$VENCORD_USER_DATA_DIR/${file.target}";
            escapedTarget = wlib.escapeShellArgWithEnv target;
            escapedSeedSource = wlib.escapeShellArgWithEnv "$shared_config_dir/${file.target}";
          in
          ''
            source=${escapedSeedSource}
            if [ -z "$shared_config_dir" ] || [ ! -e "$source" ]; then
              source=${lib.escapeShellArg file.source}
            fi
            ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname ${escapedTarget})"
            ${pkgs.coreutils}/bin/rm -f ${escapedTarget}
            ${pkgs.coreutils}/bin/install -m 0644 "$source" ${escapedTarget}
          ''
        ) managedFiles}
      ''
    ];
}
