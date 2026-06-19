{ rootPath, ... }:
{
  den.aspects.programs.chat.vesktop = {
    wrapper-packages =
      { fleet, ... }:
      {
        vesktop-base16 = {
          imports = [ (rootPath + /wrappers/vesktop/vesktop.nix) ];
          instanceName = "base16";
          inherit (fleet.my) fonts;
          colors = fleet.my.base16.scheme.withHashtag;
        };
      };

    os =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.local.vesktop-base16 ];
      };

    nixos =
      { pkgs, ... }:
      {
        environment.etc."packages/vesktop/base16".source = "${pkgs.local.vesktop-base16}/defaults";

        systemd.user.services.vesktop-start = {
          description = "Start vesktop on login";
          after = [
            "graphical-session.target"
            "graphical-session-pre.target"
          ];
          wantedBy = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
            ExecStart = "${pkgs.local.vesktop-base16}/bin/vesktop-base16 --silent";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      };
  };
}
