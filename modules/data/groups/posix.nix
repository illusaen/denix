# Group definitions — user roles, system gates, service access, and POSIX groups.
_: {
  den.groups = {
    # POSIX groups (Unix permissions with gidNumber)
    # Members of workstation-access also inherit most of these groups.
    wheel = {
      labels = [ "posix" ];
      gid = 1;
      description = "Sudo access";
      members = [ "workstation-access" ];
    };
    tty = {
      labels = [ "posix" ];
      gid = 3;
      description = "TTY access";
      members = [ "workstation-access" ];
    };
    audio = {
      labels = [ "posix" ];
      gid = 17;
      description = "Audio device access";
      members = [ "workstation-access" ];
    };
    video = {
      labels = [ "posix" ];
      gid = 26;
      description = "Video device access";
      members = [ "workstation-access" ];
    };
    networkmanager = {
      labels = [ "posix" ];
      gid = 57;
      description = "NetworkManager control";
      members = [ "workstation-access" ];
    };
    input = {
      labels = [ "posix" ];
      gid = 174;
      description = "Input device access";
      members = [ "workstation-access" ];
    };
    kvm = {
      labels = [ "posix" ];
      gid = 302;
      description = "KVM hypervisor access";
    };
    render = {
      labels = [ "posix" ];
      gid = 303;
      description = "GPU render access";
      members = [ "workstation-access" ];
    };
    media = {
      labels = [ "posix" ];
      gid = 900;
      description = "Media files access";
      members = [ "workstation-access" ];
    };
    libvirtd = {
      labels = [ "posix" ];
      gid = 901;
      description = "VM management access";
    };
    gamemode = {
      labels = [ "posix" ];
      gid = 981;
      description = "GameMode access";
      members = [ "workstation-access" ];
    };
    i2c = {
      labels = [ "posix" ];
      gid = 984;
      description = "I2C device access for ddcutil";
      members = [ "workstation-access" ];
    };
    onepassword-secrets = {
      labels = [ "posix" ];
      gid = 985;
      description = "1Password secrets access";
      members = [ "workstation-access" ];
    };
  };
}
