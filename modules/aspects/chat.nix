{ den, lib, ... }:
{
  den.aspects.chat = {
    includes = lib.attrValues den.aspects.chat._;

    _.vesktop = {
      hm.programs.vesktop = {
        enable = true;

        vencord.settings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          notifyAboutUpdates = false;
          useQuickCss = true;
          transparent = true;

          plugins = {
            ClearURLs.enabled = true;
            FixYoutubeEmbeds.enabled = true;
            FakeNitro.enabled = true;
          };
        };
      };
    };

    _.element = den.lib.perHost {
      os =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [ element-desktop ];
        };
    };
  };
}
