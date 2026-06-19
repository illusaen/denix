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

  # Main PC
  den.aspects.odin.includes = with den.aspects; [
    boot
    boot.nvidia
    roles.desktop
  ];
}
