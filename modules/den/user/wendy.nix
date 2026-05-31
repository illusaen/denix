{ den, ... }:
{
  den.aspects.wendy = {
    includes = [ den.batteries.host-aspects ];
    user.password = "arst";
  };

  den.users.registry.wendy = {
    system.uid = 1000;
    groups = [
      "admins"
      "i2c"
      "onepassword-secrets"
      "system-access"
      "server-access"
      "libvirtd"
      "kvm"
    ];
    identity = {
      displayName = "Wendy Chen";
      accountName = "illusaen";
      email = "jaewchen@gmail.com";
      sshKeys = [ ];
    };
  };
}
