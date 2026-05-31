# Colmena battery: policy-driven hive from host entities.
#
# Aspects emit tag lists into the colmena class (e.g. colmena = [ "server" ]).
# policy.instantiate collects and flattens them per-host into
# flake.colmenaDeployment.<host>, then the hive reads them as tags.
{
  den,
  lib,
  config,
  inputs,
  self,
  withSystem,
  ...
}:
let
  DEFAULT_USER = "wendy";
  DEFAULT_TARGET_HOST_DOMAIN = "lan";

  allHosts = lib.foldl' (acc: system: acc // (config.den.hosts.${system} or { })) { } (
    builtins.attrNames (config.den.hosts or { })
  );

  # Channel → nixpkgs input mapping.  Duplicates the table in host.nix but
  # avoids touching self.nixosConfigurations (which forces full host eval).
  channelNixpkgs = {
    inherit (inputs) nixpkgs-unstable;
    inherit (inputs) nixpkgs-master;
  };

  hiveConfig =
    {
      localSystem ? "x86_64-linux",
      ...
    }:
    let
      deploymentData = config.flake.colmenaDeployment or { };

      nodes = lib.mapAttrs (
        name: host:
        let
          isDarwin = host.class == "darwin";
          osConfig = if isDarwin then self.darwinConfigurations.${name} else self.nixosConfigurations.${name};
          hostTags = deploymentData.${name} or [ ];
        in
        {
          imports = osConfig._module.args.modules;
          deployment = {
            targetHost =
              let
                inherit (host) ipv4;
              in
              if ipv4 == [ ] then "${name}.${DEFAULT_TARGET_HOST_DOMAIN}" else builtins.head ipv4;
            tags = [ (host.environment or "default") ] ++ hostTags;
            allowLocalDeployment = true;
            buildOnTarget = (host.system or localSystem) != localSystem;
            targetUser = host.remote-deployment-user or DEFAULT_USER;
          }
          // lib.optionalAttrs isDarwin { systemType = "darwin"; };
        }
      ) allHosts;
    in
    nodes
    // {
      meta = {
        nixpkgs = withSystem localSystem ({ pkgs, ... }: pkgs);
        nix-darwin = inputs.darwin;
        # Per-node nixpkgs: colmena uses npkgs.path to find eval-config.nix.
        # Derived from host entity channel (cheap) rather than the evaluated
        # nixosConfiguration (expensive).  Bare import avoids colmena's
        # nixpkgsModule double-applying overlays/config.
        nodeNixpkgs = lib.mapAttrs (
          _: host:
          import channelNixpkgs.${host.channel or "nixos-unstable"} {
            inherit (host) system;
          }
        ) allHosts;
      };
    };
in
{
  flake-file.inputs.colmena.url = "github:zhaofengli/colmena";

  # Colmena class — aspects emit static tag lists into this.
  den.classes.colmena.description = "Colmena deployment tags";

  # Per-host: instantiate colmena class, flatten tag lists.
  den.policies.host-to-colmena =
    { host, ... }:
    [
      (den.lib.policy.instantiate {
        name = "${host.name}-colmena";
        class = "colmena";
        instantiate =
          { modules, ... }:
          lib.concatMap (m: if m ? imports then lib.flatten m.imports else lib.toList m) modules;
        intoAttr = [
          "colmenaDeployment"
          host.name
        ];
      })
    ];

  den.schema.host.includes = [
    den.policies.host-to-colmena
  ];

  flake.colmenaHive = inputs.colmena.lib.makeHive hiveConfig;

  # Emit colmena CLI into devshell via class routing
  den.aspects.devshell.colmena = {
    devshell =
      { inputs', pkgs, ... }:
      let
        colmena = inputs'.colmena.packages.colmena.override {
          nix-eval-jobs = pkgs.lixPackageSets.latest.nix-eval-jobs;
        };
      in
      {
        packages = [ colmena ];
        commands = [
          {
            package = colmena;
            help = "Build and deploy this nix config to nodes";
          }
        ];
      };
  };
  den.schema.flake-parts.includes = [ den.aspects.devshell.colmena ];
}
