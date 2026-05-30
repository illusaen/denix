# Group definitions — user roles, system gates, service access, and POSIX groups.
_: {
  den.groups = {
    # User role groups (identity & login gates)
    admins = {
      labels = [
        "user-role"
        "oauth-grant"
      ];
      description = "Full administrative access";
    };
    users = {
      labels = [
        "user-role"
        "oauth-grant"
      ];
      description = "Standard user access";
      members = [ "admins" ];
    };

    # System login gates
    system-access = {
      labels = [
        "user-role"
        "posix"
      ];
      gid = 951;
      description = "Login access to all hosts";
    };
    workstation-access = {
      labels = [
        "user-role"
        "posix"
      ];
      gid = 950;
      description = "Login access to workstation hosts";
      members = [ "system-access" ];
    };
    server-access = {
      labels = [
        "user-role"
        "posix"
      ];
      gid = 949;
      description = "Login access to server hosts";
      members = [ "system-access" ];
    };

    # POSIX groups (Unix permissions with gidNumber)
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
      description = "TTY access";
      members = [ "workstation-access" ];
    };
    onepassword-secrets = {
      labels = [ "posix" ];
      gid = 985;
      description = "TTY access";
      members = [ "workstation-access" ];
    };
  };
}
