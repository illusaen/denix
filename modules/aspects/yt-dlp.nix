{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.yt-dlp ];
  den.aspects.yt-dlp = den.lib.perHost {
    fish =
      { config, ... }:
      {
        shellAbbrs.yt =
          let
            browser =
              if
                (builtins.any (p: p ? pname && p.pname == "google-chrome") config.environment.systemPackages)
              then
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
