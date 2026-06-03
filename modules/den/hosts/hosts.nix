{ den, ... }:
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
  den.aspects.odin.includes = with den.aspects; [
    boot
    boot.nvidia
    wm
    roles.desktop
  ];

  # Macbook
  den.aspects.idunn.includes = with den.aspects; [
    mac
    roles.desktop
  ];

  # Seedbox server and Bootable ISO
  den.aspects.huginn.includes = with den.aspects; [
    iso
    boot
    roles.server
  ];

  # Raspberry Pi - backup services
  den.aspects.muninn.includes = with den.aspects; [
    boot
    roles.server
  ];
}
