{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.yt-dlp ];
  den.aspects.yt-dlp = den.lib.perHost {
    os =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      let
        browser =
          if
            (builtins.any (p: p ? pname && p.pname == "google-chrome") config.environment.systemPackages)
          then
            "--cookies-from-browser chrome"
          else
            "";
      in
      {
        environment.systemPackages = with pkgs; [ yt-dlp ];
        programs.fish = lib.mkIf config.programs.fish.enable {
          shellAbbrs.yt = "yt-dlp -t aac ${browser}";
        };
      };
  };
}
