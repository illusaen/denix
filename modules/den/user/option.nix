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
          default = [
            "user"
            "hjem"
            "persistUser"
          ];
          description = "User classes that can receive host-projected config";
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
  };
}
