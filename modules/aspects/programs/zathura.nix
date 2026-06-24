{
  den.aspects.programs.zathura = {
    wrapper-packages = {host, ...}: let
      base16 = host.settings.base.base16;
      fonts = host.settings.base.fonts;
      hexToRgba = color: opacity: let
        r = base16.scheme."${color}-dec-r";
        g = base16.scheme."${color}-dec-g";
        b = base16.scheme."${color}-dec-b";
      in "rgba(${r},${g},${b},${toString opacity})";
    in {
      zathura = {wlib, ...}: {
        imports = [wlib.wrapperModules.zathura];
        mappings = {
          "<C-o>" = "file_chooser";
        };
        settings = with base16.scheme.withHashtag; {
          guioptions = "vcs";
          adjust-open = "width";
          statusbar-basename = true;
          render-loading = false;
          scroll-step = 120;
          selection-clipboard = "clipboard";
          font = "monospace normal ${toString fonts.sizes.applications}";
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
          highlight-color = hexToRgba "base0A" 0.5;
          highlight-active-color = hexToRgba "base0D" 0.5;
          completion-bg = base01;
          completion-fg = base0D;
          completion-highlight-fg = base07;
          completion-highlight-bg = base0D;
          recolor-lightcolor = base00;
          recolor-darkcolor = base06;
        };
      };
    };

    nixos = {
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = with pkgs.local; [zathura];
      xdg.mime.defaultApplications = let
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
