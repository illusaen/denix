{ den, ... }:
{
  den.aspects.wendy = {
    includes = [ den.batteries.host-aspects ];
    nixos =
      { user, ... }:
      {
        users.users.${user.name}.password = "arst";
      };
  };

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
