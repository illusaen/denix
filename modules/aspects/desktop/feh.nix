{ den, lib, ... }:
{
  den.aspects.desktop._.feh = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ feh ];
      };

    hj.xdg.mime-apps = {
      default-applications = lib.mkBefore (
        let
          application = "feh.desktop";
          mimeTypes = [
            "image/bmp"
            "image/gif"
            "image/jpeg"
            "image/jpg"
            "image/pjpeg"
            "image/png"
            "image/tiff"
            "image/x-bmp"
            "image/x-pcx"
            "image/x-png"
            "image/x-portable-anymap"
            "image/x-portable-bitmap"
            "image/x-portable-graymap"
            "image/x-portable-pixmap"
            "image/x-tga"
            "image/x-xbitmap"
            "image/heic"
          ];
        in
        lib.genAttrs mimeTypes (_: application)
      );
    };
  };
}
