{
  den.aspects.desktop.youtube = {
    provides.to-users.persistUser.directories = [ ".config/YouTube Music Desktop App" ];

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
