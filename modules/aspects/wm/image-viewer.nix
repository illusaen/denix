{ den, lib, ... }:
{
  den.aspects.wm.includes = with den.aspects.wm; [ image-viewer ];

  den.aspects.wm.image-viewer = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          image-roll
        ];
      };

    provides.to-users.hjem.xdg.mime-apps = {
      default-applications = lib.mkBefore (
        let
          application = "com.github.weclaw1.ImageRoll.desktop";
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
