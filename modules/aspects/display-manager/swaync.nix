{ rootPath, ... }: {
  den.aspects.display-manager.swaync = {
    wrapper-packages =
      { fleet, ... }:
      {
        swaync =
          let
            inherit (fleet.my) fonts base16;
          in
          {
            imports = [ (rootPath + /wrappers/swaync/swaync.nix) ];
            font = fonts.sans;
            colors = base16.scheme.withHashtag;
          };
      };

    nixos =
      {
        pkgs,
        lib,
        ...
      }:
      {
        environment.systemPackages = with pkgs.local; [ swaync ];

        systemd.user.services = {
          swaync = {
            description = "Notification center";
            wantedBy = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            after = [ "graphical-session-pre.target" ];
            serviceConfig = {
              ExecStart = lib.getExe pkgs.local.swaync;
              Restart = "on-failure";
            };
          };
        };
      };
  };
}
