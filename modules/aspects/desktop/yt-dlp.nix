{ den, ... }:
{
  den.aspects.desktop.includes = with den.aspects.desktop; [ yt-dlp ];

  den.aspects.desktop.yt-dlp = {
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
      { self', ... }:
      {
        environment.systemPackages = [ self'.packages.yt-dlp ];
      };
  };
}
