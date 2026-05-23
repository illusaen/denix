{ den, ... }:
{
  den.aspects.desktop.includes = with den.aspects.desktop; [ youtube ];

  den.aspects.desktop.youtube = {
    wrapper-packages.yt-dlp =
      { wlib, ... }:
      {
        imports = [ wlib.wrapperModules.yt-dlp ];
        settings = {
          t = "aac";
          "cookies-from-browser" = "chrome";
        };
      };

    os =
      { self', pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          self'.packages.yt-dlp
          ytmdesktop
        ];
      };
  };
}
