{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.chrome ];

  den.aspects.chrome = {
    hm.programs.google-chrome.enable = true;
    darwin.homebrew.casks = [ "google-chrome@beta" ];
  };
}
