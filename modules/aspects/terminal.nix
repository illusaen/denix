{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.terminal ];

  den.aspects.terminal = {
    hmLinux.programs.kitty = {
      enable = true;
      settings = {
        # Tabs
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_activity_symbol = "↺ ";
        tab_bar_margin_height = "0.0 8.0";
        tab_bar_margin_width = "0.0";
        placement_strategy = "bottom-left";

        # Window
        opacity = 1;
        window_padding_width = 8;
        active_border_color = "none";

        # Misc
        confirm_os_window_close = 0;
        linux_display_server = "wayland";
        macos_titlebar_color = "system";
      };
      quickAccessTerminalConfig = {
        lines = 48;
        hide_on_focus_loss = "yes";
        margin_left = "1600";
        margin_right = "1600";
      };
    };
    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ iterm2 ];
        environment.etc."iterm2.plist".source = ../../resources/com.googlecode.iterm2.plist;
      };
  };
}
