{ den, ... }:
{
  den.hosts.aarch64-darwin.idunn = {
    channel = "nixpkgs-unstable";
    environment = "dev";
    system-owner = "wendy";
    system-access-groups = [ "workstation-access" ];
  };

  # Macbook
  den.aspects.idunn.includes = with den.aspects; [
    roles.desktop
  ];
}
