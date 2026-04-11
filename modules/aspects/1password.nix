{ den, lib, ... }:
{
  den.ctx.host.includes = [ den.aspects.onepassword ];

  den.aspects.onepassword =
    { host, ... }:
    {
      os = {
        programs._1password.enable = true;
        programs._1password-gui = {
          enable = true;
          polkitPolicyOwners = lib.mapAttrsToList (_: value: value.userName) host.users;
        };
      };

      hmLinux =
        { osConfig, ... }:
        {
          xdg.autostart.entries = [
            "${osConfig.programs._1password-gui.package}/share/applications/1password.desktop"
          ];
        };
    };
}
