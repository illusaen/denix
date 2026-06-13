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
  config.settings = { };
  config."config.rasi".content = ''
    configuration {
      display-drun: "Applications";
      drun-display-format: "{name}";
      font: "${config.font} 13";
      icon-theme: "${config.icon}";
      modi: "drun,run,window,calc";
      show-icons: true;
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
      lib.nameValuePair "${layout}Theme" (
        let
          theme = pkgs.replaceVars file {
            inherit (config.colors)
              base00
              base01
              base03
              base04
              base05
              base09
              ;
          };
        in
        {
          relPath = "rofi-theme-${layout}.rasi";
          builder = ''
            mkdir -p "$(dirname "$2")"
            {
              echo '@media ( enabled: env(ROFI_LAYOUT_${lib.toUpper layout}, false)) {'
              cat ${lib.escapeShellArg theme}
              echo '}'
            } > "$2"
          '';
        }
      )
    ) themeFile;
}
