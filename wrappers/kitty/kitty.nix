{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.modules.kitty ];
  options.renderScheme = lib.mkOption {
    type = lib.types.raw;
    description = "base16 scheme renderer";
  };

  config = {
    settings = {
      active_border_color = "none";
      background_opacity = 0.6;
      background_blur = 20;
      confirm_os_window_close = 0;
      linux_display_server = "wayland";
      macos_titlebar_color = "system";
      placement_strategy = "bottom-left";
      tab_activity_symbol = "↺";
      tab_bar_margin_height = "0.0 8.0";
      tab_bar_margin_width = "0.0";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      window_padding_width = 20;
    };
    extraConfig = ''
      # Shell integration is sourced and configured manually
      shell_integration no-rc
      include themes/cosmic.conf
    '';
    drv = {
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/kitten --set KITTY_CONFIG_DIRECTORY $out
      '';
    };
  };

  config.constructFiles = {
    generatedQuickAccessTerminalConfig = {
      relPath = "quick-access-terminal.conf";
      content = ''
        hide_on_focus_loss yes
        lines 48
        margin_left 1600
        margin_right 1600
      '';
    };
    generatedTheme =
      let
        kitty-theme = config.renderScheme {
          inherit pkgs lib;
          template = ./kitty-theme.conf.mustache;
          extension = "conf";
        };
      in
      {
        relPath = "themes/cosmic.conf";
        builder = ''
          mkdir -p "$(dirname "$2")"
          ln -s ${lib.escapeShellArg kitty-theme} "$2"
        '';
      };
  };
}
