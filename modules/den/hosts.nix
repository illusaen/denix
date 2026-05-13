{ den, lib, ... }:
let
  _disko =
    host:
    (import ../aspects/nix/boot/_disko.nix {
      inherit (host.preservation) disk persistMount rollbackSnapshot;
    });
in
{
  den.hosts.x86_64-linux.odin = {
    users.wendy = { };
    ip = "192.168.1.163";
    preservation.disk = "nvme1n1";
  };
  den.hosts.x86_64-linux.thor = {
    users.wendy = { };
    ip = "192.168.1.164";
    preservation.disk = "nvme1n1";
  };
  den.hosts.aarch64-darwin.idunn = {
    users.wendy = { };
  };

  # Main PC
  den.aspects.odin =
    { host }:
    {
      disko = _disko host;

      includes = with den.aspects; [
        amd
        nvidia
        desktop
        nix
        wm
      ];
    };

  # Macbook
  den.aspects.idunn.includes = with den.aspects; [
    desktop
    mac
  ];

  # Seedbox server and Bootable ISO
  den.aspects.thor =
    { host }:
    {
      disko = _disko host;

      includes = with den.aspects; [
        iso
        nix
      ];
    };

  # Common user
  den.aspects.wendy =
    { host, ... }:
    {
      includes = [ den.batteries.primary-user ];
    }
    // lib.optionalAttrs (host.class == "nixos") {
      user.password = "arst";
    };
}
