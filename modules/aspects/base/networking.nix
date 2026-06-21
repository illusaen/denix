{
  den.aspects.base.networking = {
    host-addrs = {
      environment,
      host,
      ...
    }: {
      hostname = host.name;
      domain = "${environment.name}.${environment.domain}";
      inherit (host) ipv4;
      publicKeyFile = host.public_key;
    };

    nixos = {
      host,
      lib,
      host-addrs,
      config,
      ...
    }: let
      peers = lib.filter (e: e.hostname != config.networking.hostName && e.ipv4 != []) host-addrs;
      hosts = lib.listToAttrs (
        map (
          entry:
            lib.nameValuePair (builtins.head entry.ipv4) [
              entry.hostname
              "${entry.hostname}.${entry.domain}"
            ]
        )
        peers
      );
    in {
      networking.networkmanager.enable = true;

      systemd.network = {
        enable = true;
        wait-online.enable = false;
        networks = {
          "10-lan" = {
            matchConfig.Name = "eno1";
            address = ["${lib.head host.ipv4}/24"];
            routes = [{Gateway = "192.0.1.1";}];
            linkConfig.RequiredForOnline = "routable";
          };
        };
      };

      networking.hosts = hosts;
    };

    darwin = {config, ...}: {
      networking.computerName = config.networking.hostName;
    };

    os = {
      lib,
      host-addrs,
      config,
      ...
    }: {
      programs.ssh.knownHosts = lib.listToAttrs (
        map (
          entry:
            lib.nameValuePair entry.hostname {
              hostNames =
                [
                  entry.hostname
                  "${entry.hostname}.${entry.domain}"
                ]
                ++ entry.ipv4;
              inherit (entry) publicKeyFile;
            }
        ) (lib.filter (e: e.hostname != config.networking.hostName && e.publicKeyFile != null) host-addrs)
      );
    };

    persist.directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
