{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.google-chrome ];

  den.aspects.google-chrome = den.lib.perHost {
    persistUser.directories = [ ".config/google-chrome" ];

    darwin.homebrew.casks = [ "google-chrome@beta" ];

    nixos =
      { pkgs, ... }:
      let
        chrome-exec = "${pkgs.google-chrome}/bin/google-chrome-stable --force-device-scale-factor=1.2";

        google-chrome-desktop = pkgs.makeDesktopItem {
          name = "google-chrome";
          desktopName = "Google Chrome";
          genericName = "Web Browser";
          comment = "Access the Internet";
          icon = "google-chrome";
          exec = "${chrome-exec} %U";
          mimeTypes = [
            "application/pdf"
            "application/rdf+xml"
            "application/rss+xml"
            "application/xhtml+xml"
            "application/xhtml_xml"
            "application/xml"
            "text/html"
            "text/xml"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/google-chrome"
            "image/webp"
          ];
          categories = [
            "Network"
            "WebBrowser"
          ];
          startupNotify = true;
          terminal = false;
          actions = {
            new-window = {
              name = "New Window";
              exec = chrome-exec;
            };
            new-private-window = {
              name = "New Private Window";
              exec = "${chrome-exec} --incognito";
            };
          };
        };
      in
      {
        environment.systemPackages = with pkgs; [
          google-chrome
          (lib.hiPrio google-chrome-desktop)
        ];
      };
  };
}
