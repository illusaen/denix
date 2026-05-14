{ den, ... }:
{
  den.aspects.base.includes = with den.aspects.base; [ terminal ];

  den.aspects.base.terminal = {
    # wrapperPackages =
    #   { osConfig, ... }:
    #   {
    #     kitty =
    #       {
    #         wlib,
    #         lib,
    #         ...
    #       }:
    #       let
    #         kitty-theme = osConfig.scheme {
    #           template = ./kitty-theme.conf.mustache;
    #           extension = "conf";
    #         };
    #       in
    #       {
    #         imports = [ wlib.wrapperModules.kitty ];
    #         font = {
    #           inherit (osConfig.my.fonts.mono) name;
    #           size = osConfig.my.fonts.sizes.terminal;
    #         };
    #         settings = {
    #           active_border_color = "none";
    #           background_opacity = 0.6;
    #           background_blur = 20;
    #           confirm_os_window_close = 0;
    #           linux_display_server = "wayland";
    #           macos_titlebar_color = "system";
    #           placement_strategy = "bottom-left";
    #           tab_activity_symbol = "↺";
    #           tab_bar_margin_height = "0.0 8.0";
    #           tab_bar_margin_width = "0.0";
    #           tab_bar_style = "powerline";
    #           tab_powerline_style = "slanted";
    #           window_padding_width = 20;
    #         };
    #         extraConfig = ''
    #           # Shell integration is sourced and configured manually
    #           shell_integration no-rc

    #           include themes/colors.conf
    #         '';
    #         constructFiles = {
    #           "quick-access-terminal.conf" = {
    #             relPath = "quick-access-terminal.conf";
    #             content = ''
    #               hide_on_focus_loss yes
    #               lines 48
    #               margin_left 1600
    #               margin_right 1600
    #             '';
    #           };
    #           "colors.conf" = {
    #             relPath = "themes/colors.conf";
    #             builder = ''
    #               mkdir -p "$(dirname "$2")"
    #               ln -s ${lib.escapeShellArg kitty-theme} "$2"
    #             '';
    #           };
    #         };
    #       };
    #   };

    nixos =
      { config, pkgs, ... }:
      let
        kitty-theme = config.scheme {
          template = ./kitty-theme.conf.mustache;
          extension = "conf";
        };
        kitty-settings = pkgs.writeText "kitty.conf" ''
          font_family ${config.my.fonts.mono.name}
          font_size ${toString config.my.fonts.sizes.terminal}

          # Shell integration is sourced and configured manually
          shell_integration no-rc

          active_border_color none
          background_opacity 0.6
          background_blur 20
          confirm_os_window_close 0
          linux_display_server wayland
          macos_titlebar_color system
          placement_strategy bottom-left
          tab_activity_symbol ↺
          tab_bar_margin_height 0.0 8.0
          tab_bar_margin_width 0.0
          tab_bar_style powerline
          tab_powerline_style slanted
          window_padding_width 20

          include themes/colors.conf
        '';
        kitty-quick-settings = pkgs.writeText "quick-access-terminal.conf" ''
          hide_on_focus_loss yes
          lines 48
          margin_left 1600
          margin_right 1600
        '';

        kitty-wrapped = pkgs.symlinkJoin {
          name = "kitty";
          paths = [ pkgs.kitty ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out/themes
            install -Dm644 ${kitty-settings} $out/kitty.conf
            install -Dm644 ${kitty-quick-settings} $out/quick-access-terminal.conf
            install -Dm644 ${kitty-theme} $out/themes/colors.conf
            wrapProgram $out/bin/kitty --add-flag --config --add-flag $out/kitty.conf --add-flag --themes-dir --add-flag $out/themes --set KITTY_CONFIG_DIRECTORY $out
            wrapProgram $out/bin/kitten --set KITTY_CONFIG_DIRECTORY $out
          '';
        };
      in
      {
        environment.systemPackages = with pkgs; [
          # self'.packages.kitty
          ghostty
          kitty-wrapped
        ];
        systemd.packages = [ pkgs.ghostty ];
        services.dbus.packages = [ pkgs.ghostty ];

      };

    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ ghostty-bin ];
      };

    provides.to-users.hjem =
      {
        pkgs,
        lib,
        osConfig,
        ...
      }:
      {
        xdg.config.files = {
          "ghostty/config.ghostty".text = ''
            font-family = ${osConfig.my.fonts.mono.name}
            font-size = ${toString osConfig.my.fonts.sizes.terminal}

            background-opacity = 0.9
            background-opacity-cells = true
            background-blur = macos-glass-regular

            window-padding-x = 16
            window-padding-y = 16
            window-padding-balance = true

            macos-hidden = always

            command = ${lib.getExe pkgs.fish}
            keybind = global:cmd+backquote=toggle_quick_terminal
            quit-after-last-window-closed = false
            theme = Cosmic.ghostty
          '';
          "ghostty/themes/Cosmic.ghostty".source = osConfig.scheme {
            template = ./theme.ghostty.mustache;
            extension = "ghostty";
          };
        };
      };
  };
}
