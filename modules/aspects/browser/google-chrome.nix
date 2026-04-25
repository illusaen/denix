{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.google-chrome ];

  den.aspects.google-chrome = den.lib.perHost {
    persistUser.directories = [ ".config/google-chrome" ];

    darwin.homebrew.casks = [ "google-chrome@beta" ];
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ google-chrome ];
      };

    hj =
      { lib, ... }:
      {
        xdg.data.files."applications/google-chrome.desktop".source = ./google-chrome.desktop;
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
}
