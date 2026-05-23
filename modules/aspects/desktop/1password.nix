{ den, lib, ... }:
{
  den.aspects.desktop.includes = with den.aspects.desktop; [ onepassword ];

  den.aspects.desktop.onepassword = {
    os =
      { pkgs, ... }:
      {
        programs._1password.enable = true;
        programs._1password-gui = {
          enable = true;
          package = pkgs._1password-gui-beta;
        };
      };

    nixos =
      { host, config, ... }:
      {
        programs._1password-gui.polkitPolicyOwners = lib.mapAttrsToList (_: value: value.userName) host.users;

        systemd.user.services.onepassword = {
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          requires = [ "graphical-session-pre.target" ];
          after = [
            "graphical-session.target"
            "graphical-session-pre.target"
          ];
          description = "1Password";
          script = "${lib.getExe config.programs._1password-gui.package}";
        };
      };

    provides.to-users.persistUser.directories = [ ".config/1Password" ];
  };
}
