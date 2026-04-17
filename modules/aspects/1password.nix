{ den, lib, ... }:
{
  den.ctx.host.includes = [ den.aspects.onepassword ];

  den.aspects.onepassword =
    { host, ... }:
    {
      nixos.programs._1password-gui.polkitPolicyOwners = lib.mapAttrsToList (
        _: value: value.userName
      ) host.users;

      os =
        { config, ... }:
        {
          programs._1password.enable = true;
          programs._1password-gui.enable = true;

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

      persistUser.directories = [ ".config/1Password" ];
    };
}
