{
  den,
  lib,
  self,
  ...
}:
{
  den.aspects.base.includes = with den.aspects.base; [ terminal ];

  den.aspects.base.terminal = {
    wrapper-packages =
      { host, ... }:
      let
        osConfig = (if host.class == "darwin" then self.darwinConfigurations else self.nixosConfigurations).${host.name}.config;
      in
      {
        kitty =
          { pkgs, wlib, ... }:
          let
            kitty-theme = osConfig.scheme {
              template = ./kitty-theme.conf.mustache;
              extension = "conf";
            };
            inherit (self.my) fonts;
          in
          {
            imports = [ wlib.wrapperModules.kitty ];
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
            filesToPatch = [ ];
            extraConfig = ''
              # Shell integration is sourced and configured manually
              shell_integration no-rc
              include themes/cosmic.conf
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
                relPath = "themes/cosmic.conf";
                builder = ''
                  mkdir -p "$(dirname "$2")"
                  ln -s ${lib.escapeShellArg kitty-theme} "$2"
                '';
              };
            };
            drv = {
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postBuild = ''
                wrapProgram $out/bin/kitten --set KITTY_CONFIG_DIRECTORY $out
              '';
            };
          };
      };

    os =
      { self', ... }:
      {
        environment.systemPackages = [
          self'.packages.kitty
        ];
      };
  };
}
