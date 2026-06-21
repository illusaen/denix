{den, ...}: {
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

    networking.interfaces.eno1.ipv4 = ["192.168.1.164/24"];
  };

  # Raspberry Pi - backup services
  den.aspects.muninn.includes = with den.aspects; [
    boot
    roles.server
  ];
}
