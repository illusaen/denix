{
  wlib,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ wlib.wrapperModules.rofi ];
  options = {
    font = lib.mkOption { type = lib.types.str; };
    icon = lib.mkOption { type = lib.types.str; };
    colors = lib.mkOption { type = lib.types.raw; };
  };

  config.plugins = with pkgs; [ rofi-calc ];
  config.settings = {
    modi = "drun,run,window";
    show-icons = true;
    display-drun = "Applications";
    drun-display-format = "{name}";
    font = "${config.font} 13";
    icon-theme = "${config.icon}";
  };
  config.flags."-theme" = config.constructFiles.themeConfig.path;
  config.constructFiles.themeConfig =
    let
      theme = pkgs.replaceVars ./theme-list.rasi {
        inherit (config.colors)
          base00
          base01
          base02
          base03
          base04
          base05
          base09
          ;
      };
    in
    {
      relPath = "rofi-theme.rasi";
      builder = ''
        mkdir -p "$(dirname "$2")"
        ln -s ${lib.escapeShellArg theme} "$2"
      '';
    };
}
