{ den, lib, ... }:
let
  _disko =
    host:
    (import ../../aspects/nix/boot/_disko.nix {
      inherit (host.preservation) disk persistMount rollbackSnapshot;
    });
in
{
  den.hosts.x86_64-linux.odin = {
    preservation.disk = "nvme1n1";

    channel = "nixpkgs-unstable";
    environment = "dev";
    system-owner = "wendy";
    system-access-groups = [
      "workstation-access"
      "system-access"
    ];
  };

  den.hosts.x86_64-linux.thor = {
    preservation.disk = "nvme1n1";

    channel = "nixpkgs-unstable";
    environment = "dev";
    system-owner = "wendy";
    system-access-groups = [ "workstation-access" ];
  };

  den.hosts.aarch64-darwin.idunn = {
    channel = "nixpkgs-unstable";
    environment = "dev";
    system-owner = "wendy";
    system-access-groups = [ "workstation-access" ];
  };

  # Main PC
  den.aspects.odin = {
    nixos =
      { host, ... }:
      {
        disko = _disko host;
      };

    includes = with den.aspects; [
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
    nixos =
      { host, ... }:
      {
        disko = _disko host;
      };

    includes = with den.aspects; [
      iso
      nix
    ];
  };

  # Common user
  den.aspects.wendy =
    { host, ... }:
    {
      includes = [ ];
      flake-config.my.vars.userName = "wendy";
    }
    // lib.optionalAttrs (host.class == "nixos") {
      user.password = "arst";
    };
}
