{ den, lib, ... }:
{
  den.aspects.steam = {
    includes = lib.attrValues den.aspects.steam._;

    _.enable = den.lib.perHost {
      persistUser.directories = [ ".local/share/Steam" ];

      darwin =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [ steam ];
        };

      nixos =
        { pkgs, config, ... }:
        {
          programs.steam = {
            enable = true;
            package = pkgs.steam.override {
              extraPkgs =
                # pkgs': with pkgs'; [

                # ];
                _pkgs': [ config.myLib.theming.cursorTheme.package ];
            };
          };

          systemd.user.services.steam-start = {
            description = "Start Steam on login";
            after = [
              "graphical-session.target"
              "graphical-session-pre.target"
            ];
            wantedBy = [ "graphical-session.target" ];
            serviceConfig = {
              ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
              ExecStart = "${pkgs.steam}/bin/steam -silent";
              Restart = "on-failure";
              RestartSec = 5;
            };
          };
        };
    };
  };
}
