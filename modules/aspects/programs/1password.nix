{ den, lib, ... }:
{
  den.aspects.programs.onepassword = {
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
      { config, ... }:
      {
        programs._1password-gui.polkitPolicyOwners = lib.mapAttrsToList (
          _: value: value.userName
        ) den.users.registry;

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
