{ den, lib, ... }:
let
  disko = import ../aspects/boot/_disko.nix {
    inherit (den.aspects.preservation.meta.vars) disk persistMount rollbackSnapshot;
  };
in
{
  den.hosts.x86_64-linux.odin = {
    users.wendy = { };
    ip = "192.168.1.163";
  };
  den.hosts.x86_64-linux.thor = {
    users.wendy = { };
    ip = "192.168.1.164";
  };
  den.hosts.aarch64-darwin.idunn = {
    users.wendy = { };
  };

  # Main PC
  den.aspects.odin = {
    inherit disko;

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
  den.aspects.thor = {
    inherit disko;

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
