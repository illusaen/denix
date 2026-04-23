{ den, lib, ... }:
{
  den.ctx.host.includes = [ den.aspects.chrome ];
  den.ctx.user.includes = [ den.aspects.chrome ];

  den.aspects.chrome = {
    includes = lib.attrValues den.aspects.chrome._;

    _.enable = den.lib.perHost {
      persistUser.directories = [ ".config/google-chrome" ];

      darwin.homebrew.casks = [ "google-chrome@beta" ];
      nixos =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [ google-chrome ];
        };
    };

    _.configure = den.lib.perUser {
      hjem =
        { lib, ... }:
        {
          xdg.mime-apps.default-applications =
            let
              application = "google-chrome.desktop";
              mimeTypes = [
                "text/html"
                "x-scheme-handler/http"
                "x-scheme-handler/https"
                "x-scheme-handler/about"
                "x-scheme-handler/unknown"
              ];
            in
            lib.genAttrs mimeTypes (_: application);
        };
    };

  };
}
