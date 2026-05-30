{ den, ... }:
{
  den.aspects.sini = {
    includes = [ den.batteries.host-aspects ];
  };

  den.users.registry.sini = {
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
      email = "jaewchen@gmail.com";
      sshKeys = [

      ];
    };
  };
}
