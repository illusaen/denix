{
  den.aspects.base.firefox = {
    # provides.to-users.persistUser.directories = [ ".config/google-chrome" ];

    darwin.homebrew.casks = [ "firefox" ];

    nixos.programs.firefox = {
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
}
