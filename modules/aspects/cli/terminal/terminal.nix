{ den, ... }:
{
  den.aspects.cli._.terminal = den.lib.perHost {
    nixos =
      { pkgs, config, ... }:
      let
        kitty-settings = pkgs.writeText "kitty.conf" ''
          font_family ${config.myLib.fonts.mono.name}
          font_size ${toString config.myLib.fonts.sizes.terminal}

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

        kitty-wrapped = pkgs.symlinkJoin {
          name = "kitty";
          paths = [ pkgs.kitty ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out/themes
            install -Dm644 ${kitty-settings} $out/kitty.conf
            install -Dm644 ${./quick-access-terminal.conf} $out/quick-access-terminal.conf
            install -Dm644 ${./kitty-theme.conf} $out/themes/colors.conf
            wrapProgram $out/bin/kitty --add-flag --config --add-flag $out/kitty.conf --add-flag --themes-dir --add-flag $out/themes --set KITTY_CONFIG_DIRECTORY $out
            wrapProgram $out/bin/kitten --set KITTY_CONFIG_DIRECTORY $out
          '';
        };
      in
      {
        environment.systemPackages = [ kitty-wrapped ];
      };

    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ iterm2 ];
        environment.etc."iterm2.plist".source = ./com.googlecode.iterm2.plist;
        system.defaults.CustomUserPreferences = {
          "com.googlecode.iterm2".PrefsCustomFolder = "/etc/iterm2.plist";
          "com.googlecode.iterm2".LoadPrefsFromCustomFolder = true;
        };
      };
  };
}
