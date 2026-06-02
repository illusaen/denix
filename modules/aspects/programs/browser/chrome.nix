{
  den.aspects.programs.browser.chrome = {
    provides.to-users.persistUser.directories = [ ".config/google-chrome" ];

    darwin.homebrew.casks = [
      "google-chrome@beta"
    ];

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ google-chrome ];
      };
  };
}
