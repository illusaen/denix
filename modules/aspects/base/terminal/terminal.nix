{
  den,
  lib,
  self,
  ...
}:
{
  den.aspects.base.includes = with den.aspects.base; [ terminal ];

  den.aspects.base.terminal = {
    wrapper-packages.kitty =
      { pkgs, wlib, ... }:
      let
        kitty-theme = self.my.scheme.render {
          inherit pkgs lib;
          template = ./kitty-theme.conf.mustache;
          extension = "conf";
        };
        inherit (self.my) fonts;
        inherit (pkgs.stdenv) isDarwin;
      in
      {
        imports = [ wlib.wrapperModules.kitty ];
        font = {
          name = fonts.mono;
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
        ''
        + lib.optionalString isDarwin ''
          font_family family="${fonts.mono}" postscript_name=MonaspaceNeonNF-Regular
        '';
        constructFiles = {
          generatedQuickAccessTerminalConfig = {
            relPath = "quick-access-terminal.conf";
            content = ''
              hide_on_focus_loss yes
              lines 30
            ''
            + lib.optionalString (!isDarwin) ''
              margin_left 1600
              margin_right 1600
            '';
          };
          generatedTheme = {
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

    nixos =
      { self', ... }:
      {
        environment.systemPackages = [
          self'.packages.kitty
        ];
      };

    darwin.homebrew.casks = [ "kitty" ];
    provides.to-users.hjem =
      {
        lib,
        pkgs,
        self',
        ...
      }:
      lib.optionalAttrs pkgs.stdenv.isDarwin {
        xdg.config.files = {
          "kitty/kitty.conf".source = "${self'.packages.kitty.configuration.constructFiles.kittyConfig}";
          "kitty/quick-access-terminal.conf".source =
            "${self'.packages.kitty.configuration.constructFiles.generatedQuickAccessTerminalConfig}";
          "kitty/themes/cosmic.conf".source = "${self'.packages.kitty.configuration.constructFiles.generatedTheme}";
        };
      };
  };
}
