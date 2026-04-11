{
  den.aspects.noctalia.hm =
    { lib, ... }:
    {
      programs.noctalia-shell = {
        plugins.states.polkit-agent = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      services.polkit-gnome.enable = lib.mkOverride 900 false;
    };
}
