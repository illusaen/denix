{ den, ... }:
let
  _disko =
    host:
    (import ../../aspects/nix/boot/_disko.nix {
      inherit (host.preservation) disk persistMount rollbackSnapshot;
    });
in
{
  den.hosts.x86_64-linux.odin = {
    preservation.enable = true;
    preservation.disk = "nvme1n1";

    channel = "nixpkgs-unstable";
    environment = "dev";
    system-owner = "wendy";
    system-access-groups = [
      "workstation-access"
      "system-access"
    ];

    networking.interfaces.eno1.ipv4 = [ "192.168.1.162/24" ];
  };

  den.hosts.x86_64-linux.huginn = {
    preservation.enable = true;
    preservation.disk = "nvme1n1";

    channel = "nixpkgs-unstable";
    environment = "dev";
    system-owner = "wendy";
    system-access-groups = [
      "workstation-access"
      "server-access"
    ];

    networking.interfaces.eno1.ipv4 = [ "192.168.1.163/24" ];
  };

  den.hosts.x86_64-linux.muninn = {
    preservation.enable = true;
    preservation.disk = "nvme1n1";

    channel = "nixpkgs-unstable";
    environment = "dev";
    system-owner = "wendy";
    system-access-groups = [
      "workstation-access"
      "server-access"
    ];

    networking.interfaces.eno1.ipv4 = [ "192.168.1.164/24" ];
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
      nix
      wm
      roles.desktop
    ];
  };

  # Macbook
  den.aspects.idunn.includes = with den.aspects; [
    mac
    roles.desktop
  ];

  # Seedbox server and Bootable ISO
  den.aspects.huginn = {
    nixos =
      { host, ... }:
      {
        disko = _disko host;
      };

    includes = with den.aspects; [
      iso
      nix
      roles.server
    ];
  };

  # Raspberry Pi - backup services
  den.aspects.muninn = {
    nixos =
      { host, ... }:
      {
        disko = _disko host;
      };

    includes = with den.aspects; [
      nix
      roles.server
    ];
  };
}
