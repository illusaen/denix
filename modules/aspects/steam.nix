{ den, ... }:
{
  den.aspects.steam = den.lib.perHost {
    persistUser.directories = [ ".local/share/Steam" ];

    darwin =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ steam ];
      };

    nixos =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        programs.steam = {
          enable = true;
          package = pkgs.steam.override {
            extraPkgs = _pkgs': [ config.myLib.theming.cursorTheme.package ];
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
            ExecStart = "${lib.getExe config.programs.steam.package} -silent";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      };
  };
}
