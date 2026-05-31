# Fleet topology policies.
#
# Wires the scope tree: flake -> fleet -> environment -> hosts.
# Environment membership derived from den.schema.host.environment.
# Environment entities read from the legacy environments registry.
{
  lib,
  den,
  config,
  ...
}:
let
  inherit (den.lib.policy) resolve;
  inherit (config.den) environments;
  registry = config.den.users.registry;
  groups = config.den.groups;
  groupNames = builtins.attrNames groups;

  inheritedGroupsFor =
    groupName:
    builtins.filter (
      candidate:
      let
        candidateMembers = groups.${candidate}.members or [ ];
      in
      lib.elem groupName candidateMembers
    ) groupNames;

  resolveUserGroups =
    seedGroups:
    let
      go =
        seen:
        let
          next = lib.unique (seen ++ lib.concatMap inheritedGroupsFor seen);
        in
        if builtins.length next == builtins.length seen then seen else go next;
    in
    go (lib.unique seedGroups);

  matchRegistryUsers =
    grantedGroups:
    lib.filter (
      name:
      let
        userGroups = resolveUserGroups (registry.${name}.groups or [ ]);
      in
      builtins.any (g: lib.elem g grantedGroups) userGroups
    ) (builtins.attrNames registry);
in
{
  # flake -> fleet: single fleet entity (fires at flake scope).
  # secretsConfig propagates through scope inheritance to all descendants.
  den.policies.to-fleet = _: [
    (resolve.to "fleet" {
      fleet = config.fleet // {
        name = "fleet";
        # inherit (config.den) secretsConfig;
      };
    })
  ];

  # fleet -> environments: fan out per registered environment.
  den.policies.fleet-to-envs =
    _:
    lib.mapAttrsToList (
      _: env:
      resolve.to "environment" {
        environment = env;
      }
    ) environments;

  # environment -> hosts: walk den.hosts whose environment matches.
  den.policies.env-to-hosts =
    { environment, ... }:
    let
      inherit (config) fleet;
      envGrant = (fleet.user-access.by-environment.${environment.name} or { groups = [ ]; }).groups;
      envGate = environment.system-access-groups or [ ];
    in
    lib.concatMap (
      system:
      lib.concatMap (
        hostName:
        let
          hostCfg = den.hosts.${system}.${hostName};
          hostGrant = (fleet.user-access.by-host.${hostName} or { groups = [ ]; }).groups;
          hostGate = hostCfg.system-access-groups;
          # Effective gate: union of env + host gates (matching main's mergedAccessGroups)
          effectiveGate = lib.unique (envGate ++ hostGate);
          # Effective grant: union of env + host grants
          allGrants = lib.unique (envGrant ++ hostGrant);
          # Users must match both a grant AND a gate group
          accessGroups =
            if effectiveGate == [ ] then
              allGrants
            else
              builtins.filter (g: builtins.elem g effectiveGate) allGrants;
          matchedUsers = matchRegistryUsers accessGroups;
          resolvedUsers = builtins.listToAttrs (
            map (name: {
              inherit name;
              value = registry.${name};
            }) matchedUsers
          );
        in
        lib.optionals ((hostCfg.environment or "prod") == environment.name && hostCfg.intoAttr != [ ]) [
          (resolve.to "host" {
            host = hostCfg // {
              users = (hostCfg.users or { }) // resolvedUsers;
            };
            inherit accessGroups;
          })
          (den.lib.policy.instantiate hostCfg)
        ]
      ) (builtins.attrNames (den.hosts.${system} or { }))
    ) (builtins.attrNames (den.hosts or { }));

  # Schema wiring.
  den.schema.flake.includes = [ den.policies.to-fleet ];
  den.schema.fleet.includes = [ den.policies.fleet-to-envs ];
  den.schema.environment.includes = [ den.policies.env-to-hosts ];

  # Fleet handles host instantiation -- exclude default walking policies.
  den.schema.flake-system.excludes = [
    den.policies.system-to-os-outputs
    den.policies.system-to-hm-outputs
  ];
}
