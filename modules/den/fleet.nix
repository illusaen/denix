# Fleet-wide configuration and user access grants.
{
  fleet.user-access = {
    by-environment = {
      prod.groups = [
        "system-access"
        "workstation-access"
      ];
      dev.groups = [
        "system-access"
        "workstation-access"
        "server-access"
      ];
    };
  };
}
