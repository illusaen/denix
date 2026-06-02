{
  den.aspects.programs.browser.firefox = {
    darwin.homebrew.casks = [ "firefox" ];

    nixos = {
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
    };
  };
}
