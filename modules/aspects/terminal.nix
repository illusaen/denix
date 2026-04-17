{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.terminal ];

  den.aspects.terminal =
    { host, ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [ kitty ];
        };

      mdLinux = {
        file.xdg_config."kitty/kitty.conf".text = ''
          font_family ${host.fonts.mono.name}
          font_size ${toString host.fonts.sizes.terminal}

          # Shell integration is sourced and configured manually
          shell_integration no-rc

          active_border_color none
          background_opacity 1.000000
          confirm_os_window_close 0
          linux_display_server wayland
          macos_titlebar_color system
          opacity 1
          placement_strategy bottom-left
          tab_activity_symbol ↺ 
          tab_bar_margin_height 0.0 8.0
          tab_bar_margin_width 0.0
          tab_bar_style powerline
          tab_powerline_style slanted
          window_padding_width 8

          include themes/colors.conf
        '';

        file.xdg_config."kitty/quick-access-terminal.conf".text = ''
          hide_on_focus_loss yes
          lines 48
          margin_left 1280
          margin_right 1280
        '';

        file.xdg_config."kitty/themes/colors.conf".source = ../../resources/themes/kitty.conf;
      };

      darwin =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [ iterm2 ];
          environment.etc."iterm2.plist".source = ../../resources/com.googlecode.iterm2.plist;
        };
    };
}
