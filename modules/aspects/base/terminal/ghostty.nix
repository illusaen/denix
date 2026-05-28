{ self, ... }:
{
  den.aspects.base.terminal.ghostty = {
    # TODO: fix issues with config file not loading
    # wrapper-packages.ghostty = {
    #   imports = [ ../../../../wrappers/ghostty/ghostty.nix ];
    #   renderScheme = self.my.scheme.render;
    #   font = {
    #     name = self.my.fonts.mono;
    #     size = self.my.fonts.sizes.terminal;
    #   };
    # };

    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ ghostty-bin ];
      };

    provides.to-users.hjem =
      {
        pkgs,
        lib,
        ...
      }:
      let
        inherit (self.my) fonts;
        themeFile = "Cosmic.ghostty";
      in
      {
        xdg.config.files = {
          "ghostty/config.ghostty".text = ''
            font-family = ${fonts.mono}
            font-size = ${toString fonts.sizes.terminal}

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
            theme = ${themeFile}
          '';
          "ghostty/themes/${themeFile}".source = self.my.scheme.render {
            inherit pkgs lib;
            template = ../../../../wrappers/ghostty/ghostty.theme.mustache;
            extension = "ghostty";
          };
        };
      };
  };
}
