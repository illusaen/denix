{
  den.aspects.programs.zathura = {
    wrapper-packages =
      { fleet, ... }:
      let
        hexToRgba =
          hexStr: opacity:
          let
            # Ensure the string is formatted like 0xAABBCC for TOML parsing
            r = fromTOML "x = 0x${builtins.substring 1 2 hexStr}";
            g = fromTOML "x = 0x${builtins.substring 3 2 hexStr}";
            b = fromTOML "x = 0x${builtins.substring 5 2 hexStr}";
          in
          "rgba(${toString r.x},${toString g.x},${toString b.x},${toString opacity})";
      in
      {
        zathura = { wlib, ... }: {
          imports = [ wlib.wrapperModules.zathura ];
          mappings = {
            "<C-o>" = "file_chooser";
          };
          settings = with fleet.my.base16.scheme.withHashtag; {
            guioptions = "vcs";
            adjust-open = "width";
            statusbar-basename = true;
            render-loading = false;
            scroll-step = 120;
            selection-clipboard = "clipboard";
            font = "monospace normal ${toString fleet.my.fonts.sizes.applications}";
            default-bg = base00;
            default-fg = base01;
            statusbar-fg = base04;
            statusbar-bg = base02;
            inputbar-bg = base00;
            inputbar-fg = base07;
            notification-bg = base00;
            notification-fg = base07;
            notification-error-bg = base00;
            notification-error-fg = base08;
            notification-warning-bg = base00;
            notification-warning-fg = base08;
            highlight-color = hexToRgba base0A 0.5;
            highlight-active-color = hexToRgba base0D 0.5;
            completion-bg = base01;
            completion-fg = base0D;
            completion-highlight-fg = base07;
            completion-highlight-bg = base0D;
            recolor-lightcolor = base00;
            recolor-darkcolor = base06;
          };
        };
      };

    nixos = { pkgs, lib, ... }: {
      environment.systemPackages = with pkgs.local; [ zathura ];
      xdg.mime.defaultApplications =
        let
          application = "org.pwmt.zathura.desktop";
          mimeTypes = [
            "application/pdf"
            "application/epub+zip"
            "application/postscript"
          ];
        in
        lib.genAttrs mimeTypes (_: application);
    };
  };
}
