{ den, ... }:
{
  den.aspects.desktop.includes = with den.aspects.desktop; [ steam ];

  den.aspects.desktop.steam = {
    provides.to-users.persistUser.directories = [ ".local/share/Steam" ];

    darwin.homebrew.casks = [ "steam" ];

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
            extraPkgs = _pkgs': [ config.my.theming.cursorTheme.package ];
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
