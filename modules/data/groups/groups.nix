# Group definitions — user roles, system gates, service access, and POSIX groups.
_: {
  den.groups = {
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
      # Members of system-access also inherit workstation-access.
      members = ["system-access"];
    };
    server-access = {
      labels = [
        "user-role"
        "posix"
      ];
      gid = 949;
      description = "Login access to server hosts";
      # Members of system-access also inherit server-access.
      members = ["system-access"];
    };
  };
}
