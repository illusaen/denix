{ den, ... }:
{
  den.aspects.desktop.includes = with den.aspects.desktop; [ yt-dlp ];

  den.aspects.desktop.yt-dlp = {
    shell =
      { config, ... }:
      {
        shellAbbrs.yt =
          let
            browser =
              if (builtins.any (p: p ? pname && p.pname == "google-chrome") config.environment.systemPackages) then
                "--cookies-from-browser chrome"
              else
                "";
          in
          "yt-dlp -t aac ${browser}";
      };

    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ yt-dlp ];
      };
  };
}
