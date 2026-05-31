{
  den.aspects.desktop.browser = {
    provides.to-users.persistUser.directories = [ ".config/google-chrome" ];

    darwin.homebrew.casks = [
      "firefox"
      "google-chrome@beta"
    ];

    nixos =
      { pkgs, ... }:
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
        ];
      };
  };
}
