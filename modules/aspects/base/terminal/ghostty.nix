{
  den.aspects.base.terminal.ghostty = {
    darwin = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [ghostty-bin];
    };

    provides.to-users.hjemDarwin = {
      pkgs,
      lib,
      host,
      ...
    }: let
      fonts = host.settings.base.fonts;
      base16 = host.settings.base.base16;
      themeFile = "Cosmic.ghostty";
    in {
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
        "ghostty/themes/${themeFile}".source = base16.scheme {
          template = ../../../../wrappers/ghostty/ghostty.theme.mustache;
          extension = "ghostty";
        };
      };
    };
  };
}
