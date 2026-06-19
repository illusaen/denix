{
  wlib,
  lib,
  config,
  pkgs,
  ...
}:
let
  rofi-unwrapped = pkgs.rofi-unwrapped.override { x11Support = false; };
in
{
  imports = [ wlib.wrapperModules.rofi ];
  options = {
    font = lib.mkOption { type = lib.types.str; };
    icon = lib.mkOption { type = lib.types.str; };
    colors = lib.mkOption { type = lib.types.raw; };
  };

  config.package = pkgs.rofi.override { inherit rofi-unwrapped; };
  config.plugins = [ (pkgs.rofi-calc.override { inherit rofi-unwrapped; }) ];
  config.filesToExclude = [
    "share/applications/rofi.desktop"
    "share/applications/rofi-theme-selector.desktop"
  ];
  config.settings = { };
  config."config.rasi".content = ''
    configuration {
      display-drun: "Applications";
      drun-display-format: "{name}";
      font: "${config.font} 13";
      icon-theme: "${config.icon}";
      modi: "drun,run,window";
      show-icons: true;
    }

    * {
      bg: ${config.colors.base00}e6;
      surface: ${config.colors.base01}f2;
      border: ${config.colors.base03};
      text: ${config.colors.base05};
      muted: ${config.colors.base04};
      accent: ${config.colors.base09};
      accent-fg: ${config.colors.base02};
      font-icon: "${config.font} 36";
      
      text-color: @text;
      background-color: transparent;
    }

    window {
      border: 1px;
      border-color: @border;
      border-radius: 20px;
      background-color: @bg;
    }

    inputbar {
      border-radius: 12px;
      background-color: @surface;
    }

    listview { scrollbar: false; }

    entry { text-color: @text; placeholder: "Search"; placeholder-color: @muted; }

    textbox { text-color: @text; }

    element {
      padding: 12px;
      border-radius: 12px;
    }

    element, element-text, element-icon {
      cursor: pointer;
    }

    element normal.normal,
    element normal.active,
    element normal.urgent,
    element alternate.normal,
    element alternate.active,
    element alternate.urgent {
      background-color: @surface;
      text-color: @text;
    }

    element selected.normal,
    element selected.active,
    element selected.urgent {
        background-color: @accent;
        text-color: @accent-fg;
    }

    @import "${config.constructFiles.actionsTheme.path}"
    @import "${config.constructFiles.gridTheme.path}"
    @import "${config.constructFiles.listTheme.path}"
  '';
  config.constructFiles =
    let
      themeFile = {
        actions = ./theme-actions.rasi;
        grid = ./theme-grid.rasi;
        list = ./theme-list.rasi;
      };
    in
    lib.mapAttrs' (
      layout: file:
      lib.nameValuePair "${layout}Theme" {
        relPath = "rofi-theme-${layout}.rasi";
        content = ''
          @media ( enabled: env(ROFI_LAYOUT_${lib.toUpper layout}, false)) {
          ${builtins.readFile file}
          }
        '';
      }
    ) themeFile;
}
