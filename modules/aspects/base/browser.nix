{ den, ... }:
{
  den.aspects.base.includes = with den.aspects.base; [ browser ];

  den.aspects.base.browser = {
    provides.to-users.persistUser.directories = [ ".config/google-chrome" ];

    darwin.homebrew.casks = [
      "firefox"
      "google-chrome@beta"
    ];

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
        programs.firefox = {
          enable = true;
          languagePacks = [
            "en-US"
            "zh-CN"
          ];
          policies = {
            DisableTelemetry = true;
            DisplayMenuBar = "never";
            OfferToSaveLogins = false;
          };
          preferences = {
            "browser.startup.homepage" = "https://google.com";
          };
        };

        environment.systemPackages = with pkgs; [
          google-chrome
          (lib.hiPrio google-chrome-desktop)
        ];
      };
  };
}
