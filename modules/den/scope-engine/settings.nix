# Settings cascade scope graph.
#
# Evaluated attributes:
#   resolvedSettings - full resolved settings for a node (local > import > parent)
#   setting          - paramAttr for per-key demand-driven lookup
#   settingSources   - provenance per key (local/import/inherited)
#   overriddenKeys   - keys that shadow a parent value
{
  inputs,
  lib,
  config,
  den,
  ...
}: let
  inherit (lib) mkOption types;

  engine = inputs.scope-engine {inherit lib;};

  flatHosts = lib.foldl' (acc: system: acc // (den.hosts.${system} or {})) {} (
    builtins.attrNames (den.hosts or {})
  );

  groups = config.den.groups or {};
  environments = config.den.environments or {};
  registry = config.den.users.registry or {};
  hosts = flatHosts;

  groupNames = builtins.attrNames groups;
  envNames = builtins.attrNames environments;
  hostNames = builtins.attrNames hosts;
  userNames = builtins.attrNames registry;

  inheritedGroupsFor = groupName:
    builtins.filter (
      candidate: let
        candidateMembers = groups.${candidate}.members or [];
      in
        lib.elem groupName candidateMembers
    )
    groupNames;

  resolveUserGroups = seedGroups: let
    go = seen: let
      next = lib.unique (seen ++ lib.concatMap inheritedGroupsFor seen);
    in
      if builtins.length next == builtins.length seen
      then seen
      else go next;
  in
    go (lib.unique seedGroups);

  userGroups = uname: resolveUserGroups (registry.${uname}.groups or []);

  hostAccessGroups = hname: let
    host = hosts.${hname};
    env = environments.${host.environment or "prod"} or {};
    fleetAccess = config.fleet.user-access or {};
    envGrant = (fleetAccess.by-environment.${host.environment or "prod"} or {groups = [];}).groups;
    hostGrant = (fleetAccess.by-host.${hname} or {groups = [];}).groups;
    envGate = env.system-access-groups or [];
    hostGate = host.system-access-groups or [];
    effectiveGate = lib.unique (envGate ++ hostGate);
    allGrants = lib.unique (envGrant ++ hostGrant ++ hostGate);
  in
    if effectiveGate == []
    then allGrants
    else builtins.filter (g: builtins.elem g effectiveGate) allGrants;

  resolvedUserNamesForHost = hname: let
    accessGroups = hostAccessGroups hname;
  in
    builtins.filter (
      uname: builtins.any (g: lib.elem g accessGroups) (userGroups uname)
    )
    userNames;

  userNodeName = hname: uname: "user:${hname}:${uname}";
  userPairs =
    lib.concatMap (
      hname:
        map (uname: {
          inherit hname uname;
        })
        (resolvedUserNamesForHost hname)
    )
    hostNames;

  parentEdges = engine.overlays (
    [(engine.star "root" (map (e: "env:${e}") envNames))]
    ++ map (host: engine.edge "host:${host}" "env:${hosts.${host}.environment or "prod"}") hostNames
    ++ map (pair: engine.edge (userNodeName pair.hname pair.uname) "host:${pair.hname}") userPairs
  );

  importEdges = engine.overlays (
    lib.concatMap (
      ename: let
        delegation = environments.${ename}.delegation or {};
        targets = lib.filter (t: t != null) [
          (delegation.metricsTo or null)
          (delegation.authTo or null)
          (delegation.logsTo or null)
        ];
      in
        map (target: engine.edge "env:${ename}" "env:${target}") targets
    )
    envNames
  );

  baseNodes = engine.buildNodes {
    parentGraph = parentEdges;
    importGraph = importEdges;

    decls = lib.listToAttrs (
      [
        {
          name = "root";
          value = {};
        }
      ]
      ++ map (ename: {
        name = "env:${ename}";
        value = environments.${ename}.settings or {};
      })
      envNames
      ++ map (hname: {
        name = "host:${hname}";
        value = hosts.${hname}.settings or {};
      })
      hostNames
      ++ map (pair: {
        name = userNodeName pair.hname pair.uname;
        value = registry.${pair.uname}.system.settings or {};
      })
      userPairs
    );

    types = lib.listToAttrs (
      [
        {
          name = "root";
          value = "root";
        }
      ]
      ++ map (e: {
        name = "env:${e}";
        value = "environment";
      })
      envNames
      ++ map (h: {
        name = "host:${h}";
        value = "host";
      })
      hostNames
      ++ map (pair: {
        name = userNodeName pair.hname pair.uname;
        value = "user";
      })
      userPairs
    );
  };

  cleanDecls = node: removeAttrs node.decls ["__edges"];

  attributes = {
    children = _self: id: lib.filterAttrs (_: n: n.parent == id) baseNodes;
    imports = self: id: (self.node id).decls.__edges.I or [];

    setting = engine.paramAttr (
      self: id: key:
        engine.query {dataFilter = node: (cleanDecls node).${key} or null;} self id
    );

    resolvedSettings = self: id: let
      node = self.node id;
      local = cleanDecls node;
      importedSettings =
        lib.foldl' (
          acc: iid: engine.shadow (self.get iid "resolvedSettings") acc
        ) {}
        (self.get id "imports");
      parentSettings =
        if node.parent != null
        then self.get node.parent "resolvedSettings"
        else {};
    in
      engine.shadow local (engine.shadow importedSettings parentSettings);

    overriddenKeys = self: id: let
      allResults = key: engine.queryAll {dataFilter = node: (cleanDecls node).${key} or null;} self id;
      localKeys = builtins.attrNames (cleanDecls (self.node id));
    in
      builtins.filter (key: builtins.length (allResults key) > 1) localKeys;

    settingSources = self: id: let
      resolved = self.get id "resolvedSettings";
    in
      lib.mapAttrs (
        key: _: let
          node = self.node id;
          isLocal = (cleanDecls node) ? ${key};
          isImported =
            builtins.any (
              iid: (self.get iid "resolvedSettings") ? ${key}
            )
            (self.get id "imports");
        in
          if isLocal
          then "local"
          else if isImported
          then "import"
          else "inherited"
      )
      resolved;
  };
in {
  options.fleet.settings = mkOption {
    type = types.raw;
    description = "Evaluated settings cascade graph from scope-engine";
    readOnly = true;
  };

  config.fleet.settings = engine.eval {
    roots = baseNodes;
    inherit attributes;
  };
}
