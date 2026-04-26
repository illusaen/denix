{ den, ... }:
{
  den.aspects.discord = den.lib.perHost {
    persistUser.directories = [
      ".config/discord"
    ];

    os =
      { pkgs, ... }:
      {
        nixpkgs.overlays = [
          (_: prev: {
            discord = prev.discord.override { withOpenASAR = true; };
          })
        ];
        environment.systemPackages = with pkgs; [ discord ];

        systemd.user.services.discord-start = {
          description = "Start discord on login";
          after = [
            "graphical-session.target"
            "graphical-session-pre.target"
          ];
          wantedBy = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
            ExecStart = "${pkgs.discord}";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      };
  };
}
