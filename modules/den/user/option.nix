# User registry and access-driven user resolution policies.
#
# Users are resolved onto hosts via environment and host-level
# access group intersection. The fleet.user-access ACL mappings
# and user registry drive the resolution (following fleet-demo pattern).
{
  lib,
  den,
  config,
  ...
}:
let
  inherit (den.lib.policy) resolve;
  inherit (lib) mkOption types;

  registry = config.den.users.registry;
  groups = config.den.groups;
  groupNames = builtins.attrNames groups;

  # If group B has `members = [ "A" ]`, members of A also inherit B.
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

  resolvedRegistryGroups = name: resolveUserGroups (registry.${name}.groups or [ ]);
  resolvedPosixGroups =
    name:
    builtins.filter (groupName: lib.elem "posix" (groups.${groupName}.labels or [ ])) (
      resolvedRegistryGroups name
    );
  generatedExtraGroups =
    name:
    builtins.filter (
      groupName:
      !(builtins.elem groupName [
        # Removing these because den.batteries.primary-user already includes them
        "wheel"
        "networkmanager"
      ])
    ) (lib.unique (resolvedPosixGroups name));

  # Filter registry users whose groups intersect the granted set.
  matchRegistryUsers =
    grantedGroups:
    lib.filter (
      name:
      let
        userGroups = resolvedRegistryGroups name;
      in
      builtins.any (g: lib.elem g grantedGroups) userGroups
    ) (builtins.attrNames registry);

  collectUserProviders =
    user: aspect:
    let
      provides = aspect.provides or { };
      forwarded = lib.genAttrs (aspect.__providesForwarded or [ ]) (_: true);
      includes = aspect.includes or [ ];
    in
    lib.optional (provides ? to-users) provides.to-users
    ++ lib.optional (provides ? ${user.name}) provides.${user.name}
    ++ lib.optional (
      builtins.isAttrs aspect && aspect ? ${user.name} && !(forwarded ? ${user.name})
    ) aspect.${user.name}
    ++ lib.concatMap (collectUserProviders user) includes;

  # Submodule for group-based access grants.
  accessGrantType = types.submodule {
    options.groups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Groups granted access";
    };
  };

  # Registry entry type — mirrors the standard user entity shape so that
  # pipeline self-provide, define-user, and other batteries find the
  # expected attributes (userName, aspect, classes).
  registryUserType = types.submodule (
    { name, config, ... }:
    {
      freeformType = types.attrsOf types.anything;
      imports = [ den.schema.user ];
      config._module.args.user = config;
      options = {
        name = mkOption {
          type = types.str;
          default = name;
          description = "User name (from attrset key)";
        };
        userName = mkOption {
          type = types.str;
          default = name;
          description = "User account name";
        };
        classes = mkOption {
          type = types.listOf types.str;
          default = [ "user" ];
          description = "Home management nix classes";
        };
        aspect = mkOption {
          type = types.raw;
          default =
            let
              baseAspect = den.aspects.${name} or { };
            in
            baseAspect
            // {
              includes = (baseAspect.includes or [ ]) ++ [
                (
                  { user, ... }:
                  {
                    nixos.users.users.${user.userName}.extraGroups = generatedExtraGroups name;
                  }
                )
              ];
            };
          defaultText = "den.aspects.<name>";
          description = "Aspect that configures this user";
        };
        groups = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Group memberships for access policy selection";
        };
      };
    }
  );
in
{
  # User registry option.
  options.den.users.registry = mkOption {
    type = types.attrsOf registryUserType;
    default = { };
    description = "User registry with extended schema for fleet policy resolution";
  };

  # Access mappings: under fleet (following fleet-demo pattern).
  options.fleet.user-access = {
    by-environment = mkOption {
      type = types.attrsOf accessGrantType;
      default = { };
      description = "Grant user groups access to all hosts in an environment";
    };
    by-host = mkOption {
      type = types.attrsOf accessGrantType;
      default = { };
      description = "Grant user groups access to a specific host";
    };
  };

  config = {
    # Promote users to real entities.
    den.schema.user.isEntity = true;
    den.schema.user.classes = lib.mkDefault [ "hjem" ];

    # host -> users: resolve registry users whose groups intersect the
    # effective access groups (merged env + host, propagated via scope context).
    den.policies.env-users =
      {
        host,
        accessGroups ? [ ],
        ...
      }:
      let
        matched = matchRegistryUsers accessGroups;
        hostProviderRoots = [
          host.aspect
        ]
        ++ builtins.filter builtins.isAttrs (config.den.schema.host.includes or [ ]);
      in
      lib.concatMap (
        name:
        let
          user = registry.${name};
        in
        [
          (resolve.shared.withIncludes (lib.concatMap (collectUserProviders user) hostProviderRoots) {
            inherit user;
          })
        ]
      ) matched;
  };
}
