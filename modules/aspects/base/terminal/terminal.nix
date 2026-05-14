{
  den,
  lib,
  inputs,
  ...
}:
{
  den.aspects.base.includes = with den.aspects.base; [ terminal ];

  den.aspects.base.terminal = {
    wrapper-packages =
      ctx@{ config, ... }:
      let
        osConfig = builtins.trace (lib.attrNames config) config;
        # osConfig = (if host.class == "darwin" then self.darwinConfigurations else self.nixosConfigurations).${host.name}.config;
      in
      builtins.trace (lib.attrNames ctx) {
        kitty =
          let
            kitty-theme = osConfig.scheme {
              template = ./kitty-theme.conf.mustache;
              extension = "conf";
            };
            inherit (osConfig.my) fonts;
          in
          {
            imports = [ inputs.wrappers.lib.wrapperModules.kitty ];
            font = {
              inherit (fonts.mono) name;
              size = fonts.sizes.terminal;
            };
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
            themeFile = "cosmic";
            extraConfig = ''
              # Shell integration is sourced and configured manually
              shell_integration no-rc
            '';
            constructFiles = {
              "quick-access-terminal.conf" = {
                relPath = "quick-access-terminal.conf";
                content = ''
                  hide_on_focus_loss yes
                  lines 48
                  margin_left 1600
                  margin_right 1600
                '';
              };
              "cosmic.conf" = {
                relPath = "kitty-themes/colors.conf";
                builder = ''
                  mkdir -p "$(dirname "$2")"
                  ln -s ${lib.escapeShellArg kitty-theme} "$2"
                '';
              };
            };
          };
      };

    nixos =
      { self', ... }:
      {
        environment.systemPackages = [
          self'.packages.kitty
        ];
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
