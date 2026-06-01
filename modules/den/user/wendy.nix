{ den, ... }:
{
  den.aspects.wendy =
    { host, lib, ... }:
    {
      includes = [ den.batteries.host-aspects ];
    }
    // lib.optionalAttrs (host.class == "nixos") { user.password = "arst"; };

  den.users.registry.wendy = {
    system.uid = 1000;
    groups = [ "system-access" ];
    identity = {
      displayName = "Wendy Chen";
      accountName = "illusaen";
      email = "jaewchen@gmail.com";
      sshKeys = [ ];
    };
  };
}
