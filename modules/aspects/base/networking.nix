_: {
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
      environment,
      host,
      lib,
      host-addrs,
      config,
      ...
    }: let
      inherit (lib) attrNames concatMap imap0 length listToAttrs mapAttrsToList optionalAttrs optionals subtractLists unique;

      netCfg = host.networking or {};
      defaultNet = environment.networks.default or {};

      mkNameValue = name: value: {inherit name value;};

      stripCidr = addr: builtins.head (lib.splitString "/" addr);

      ipv4CidrPrefix = cidr: let
        parts = lib.splitString "/" cidr;
        network = builtins.elemAt parts 0;
        bits =
          if length parts > 1
          then builtins.elemAt parts 1
          else "32";
        octets = lib.splitString "." network;
        count =
          if bits == "8"
          then 1
          else if bits == "16"
          then 2
          else if bits == "24"
          then 3
          else 0;
      in
        if count == 0
        then ""
        else "${lib.concatStringsSep "." (lib.take count octets)}.";

      ipv4OnDefaultNetwork = addrs:
        if !(defaultNet ? cidr)
        then true
        else let
          prefix = ipv4CidrPrefix defaultNet.cidr;
        in
          prefix == "" || builtins.any (addr: lib.hasPrefix prefix (stripCidr addr)) addrs;

      mkRoute = gateway: extra:
        {
          Gateway = gateway;
          InitialCongestionWindow = 50;
          InitialAdvertisedReceiveWindow = 50;
        }
        // extra;

      effectiveDhcp = ifCfg:
        if ifCfg.dhcp != null
        then ifCfg.dhcp
        else if !(ifCfg.managed or true)
        then "none"
        else if length (ifCfg.ipv4 or []) > 0
        then "ipv6"
        else "yes";

      effectiveLinkLocal = ifCfg:
        if ifCfg.linkLocal != null
        then ifCfg.linkLocal
        else if ifCfg.managed or true
        then "ipv6"
        else "no";

      effectiveRequiredForOnline = ifCfg:
        if ifCfg.requiredForOnline != null
        then ifCfg.requiredForOnline
        else "routable";

      mkManagedNetworkConfig = ifCfg: let
        ipv4Addrs = ifCfg.ipv4 or [];
        ipv6Addrs = ifCfg.ipv6 or [];
        dhcp = effectiveDhcp ifCfg;
      in
        {
          networkConfig =
            {
              Address = ipv4Addrs ++ ipv6Addrs;
              IPv6AcceptRA = true;
              LinkLocalAddressing = effectiveLinkLocal ifCfg;
              DNS = defaultNet.dnsServers or [];
              DNSOverTLS = true;
              DNSSEC = "allow-downgrade";
            }
            // optionalAttrs (dhcp != "none") {
              DHCP = dhcp;
            };

          routes =
            optionals ((defaultNet.gatewayIp or null) != null && ipv4Addrs != [] && ipv4OnDefaultNetwork ipv4Addrs) [
              (mkRoute defaultNet.gatewayIp {})
            ]
            ++ optionals ((defaultNet.gatewayIpV6 or null) != null && ipv6Addrs != []) [
              (mkRoute defaultNet.gatewayIpV6 {
                Destination = "::/0";
                GatewayOnLink = true;
              })
            ];
          linkConfig =
            {
              RequiredForOnline = effectiveRequiredForOnline ifCfg;
            }
            // optionalAttrs (ifCfg.mtu != null) {
              MTUBytes = toString ifCfg.mtu;
            };
        }
        // optionalAttrs (dhcp != "none") {
          dhcpV6Config = {
            UseDelegatedPrefix = true;
            PrefixDelegationHint = "::/64";
          };
        };

      mkUnmanagedNetworkConfig = ifCfg: let
        ipv4Addrs = ifCfg.ipv4 or [];
        ipv6Addrs = ifCfg.ipv6 or [];
        dhcp = effectiveDhcp ifCfg;
      in {
        networkConfig =
          {
            Address = ipv4Addrs ++ ipv6Addrs;
            LinkLocalAddressing = effectiveLinkLocal ifCfg;
          }
          // optionalAttrs (dhcp != "none") {
            DHCP = dhcp;
          };
        linkConfig =
          {
            ActivationPolicy = "up";
            RequiredForOnline = effectiveRequiredForOnline ifCfg;
          }
          // optionalAttrs (ifCfg.mtu != null) {
            MTUBytes = toString ifCfg.mtu;
          };
      };

      mkNetworkConfig = ifCfg:
        if ifCfg.managed or true
        then mkManagedNetworkConfig ifCfg
        else mkUnmanagedNetworkConfig ifCfg;

      allInterfaceNames = attrNames (netCfg.interfaces or {});

      effectiveBridges =
        if (netCfg.autobridging or false) && (netCfg.bridges or {}) == {}
        then listToAttrs (imap0 (idx: ifName: mkNameValue "br${toString idx}" [ifName]) allInterfaceNames)
        else netCfg.bridges or {};

      bridgeConfig =
        map (
          brName: let
            interfaces = effectiveBridges.${brName};
          in {
            name = brName;
            inherit interfaces;
            ifCfg =
              if length interfaces > 0
              then
                netCfg.interfaces.${
                  builtins.head interfaces
                } or {
                  ipv4 = [];
                  ipv6 = [];
                }
              else {
                ipv4 = [];
                ipv6 = [];
              };
          }
        )
        (attrNames effectiveBridges);

      bridgeNames = map (br: br.name) bridgeConfig;
      bridgedInterfaces = unique (concatMap (br: br.interfaces) bridgeConfig);

      bondConfig = mapAttrsToList (bondName: bondCfg: {
        name = bondName;
        inherit (bondCfg) interfaces mode transmitHashPolicy;
        ifCfg =
          netCfg.interfaces.${
            bondName
          } or {
            ipv4 = [];
            ipv6 = [];
          };
      }) (netCfg.bonds or {});

      bondNames = map (bond: bond.name) bondConfig;
      bondedInterfaces = unique (concatMap (bond: bond.interfaces) bondConfig);

      standaloneInterfaces = subtractLists (bridgedInterfaces ++ bondedInterfaces ++ bridgeNames ++ bondNames) allInterfaceNames;
      allInterfaces = unique (allInterfaceNames ++ bridgedInterfaces ++ bridgeNames ++ bondNames);

      bridgeNetdevs = listToAttrs (
        map (
          br:
            mkNameValue br.name {
              netdevConfig = {
                Name = br.name;
                Kind = "bridge";
                MACAddress = "none";
              };
            }
        )
        bridgeConfig
      );

      bridgeLinks = listToAttrs (
        map (
          br:
            mkNameValue br.name {
              matchConfig.Name = br.name;
              linkConfig.MACAddressPolicy = "none";
            }
        )
        bridgeConfig
      );

      bondNetdevs = listToAttrs (
        map (
          bond:
            mkNameValue bond.name {
              netdevConfig = {
                Name = bond.name;
                Kind = "bond";
              };
              bondConfig =
                {
                  Mode = bond.mode;
                }
                // optionalAttrs (bond.transmitHashPolicy != null) {
                  TransmitHashPolicy = bond.transmitHashPolicy;
                };
            }
        )
        bondConfig
      );

      bridgedInterfaceNetworks = listToAttrs (
        concatMap (
          br:
            map (
              ifName:
                mkNameValue ifName {
                  enable = true;
                  matchConfig.Name =
                    if br.name == "br0"
                    then [
                      ifName
                      "vm-*"
                    ]
                    else ifName;
                  networkConfig.Bridge = br.name;
                  linkConfig.RequiredForOnline = "enslaved";
                }
            )
            br.interfaces
        )
        bridgeConfig
      );

      bondSlaveNetworks = listToAttrs (
        concatMap (
          bond:
            map (
              ifName:
                mkNameValue ifName {
                  enable = true;
                  matchConfig.Name = ifName;
                  networkConfig.Bond = bond.name;
                  linkConfig.RequiredForOnline = "enslaved";
                }
            )
            bond.interfaces
        )
        bondConfig
      );

      bridgeNetworks = listToAttrs (
        map (
          br:
            mkNameValue br.name (
              {
                enable = true;
                matchConfig.Name = br.name;
              }
              // mkNetworkConfig br.ifCfg
            )
        )
        bridgeConfig
      );

      bondDeviceNetworks = listToAttrs (
        map (
          bond:
            mkNameValue bond.name (
              {
                enable = true;
                matchConfig.Name = bond.name;
              }
              // mkNetworkConfig bond.ifCfg
            )
        )
        bondConfig
      );

      standaloneInterfaceNetworks = listToAttrs (
        map (
          ifName:
            mkNameValue ifName (
              {
                enable = true;
                matchConfig.Name = ifName;
              }
              // mkNetworkConfig netCfg.interfaces.${ifName}
            )
        )
        standaloneInterfaces
      );

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
      boot.kernelModules = [
        "tun"
        "bridge"
        "macvtap"
        "bonding"
      ];

      networking = {
        useNetworkd = true;
        useDHCP = false;
        dhcpcd.enable = false;
        hostId = builtins.substring 0 8 (builtins.hashString "md5" host.name);

        networkmanager = {
          enable = lib.mkDefault true;
          unmanaged = allInterfaces ++ bridgeNames ++ bondNames;
        };
      };

      systemd.network = {
        enable = true;
        wait-online.enable = false;
        netdevs = bridgeNetdevs // bondNetdevs;
        links = bridgeLinks;
        networks =
          bridgedInterfaceNetworks
          // bondSlaveNetworks
          // standaloneInterfaceNetworks
          // bridgeNetworks
          // bondDeviceNetworks;
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
