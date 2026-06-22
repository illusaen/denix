{
  lib,
  config,
  ...
}: let
  generatedExtraGroups = aclUser:
    builtins.filter (
      groupName:
        !(builtins.elem groupName [
          # den.batteries.primary-user already grants these where needed.
          "wheel"
          "networkmanager"
        ])
    ) (lib.unique (aclUser.systemGroups or []));

  userEnrichment = {
    host,
    user,
    ...
  }: let
    userName = user.userName or user.name;
    aclUser = config.fleet.acl.get "host:${host.name}" "resolveUser" userName;
    uid = user.system.uid or null;
    gid =
      if (user.system.gid or null) != null
      then user.system.gid
      else uid;
    sshKeys = map (key: key.key) (user.identity.sshKeys or []);
    displayName = user.identity.displayName or "";
  in {
    name = "user-enrichment/${userName}@${host.name}";

    nixos = {
      users.mutableUsers = lib.mkDefault false;

      users.groups.${userName} = lib.optionalAttrs (gid != null) {
        gid = lib.mkDefault gid;
      };

      users.users.${userName} =
        {
          extraGroups = generatedExtraGroups aclUser;
          linger = lib.mkDefault (user.system.linger or false);
          description = lib.mkDefault displayName;
          openssh.authorizedKeys.keys = sshKeys;
        }
        // lib.optionalAttrs (uid != null) {
          uid = lib.mkDefault uid;
        }
        // lib.optionalAttrs (gid != null) {
          group = lib.mkOverride 900 userName;
        };
    };
  };

  resolvedUserEmitter = {user, ...}: {
    resolved-users = {
      inherit (user) name;
      uid = user.system.uid or null;
      inherit (user) groups;
      sshKeys = map (key: key.key) (user.identity.sshKeys or []);
    };
  };
in {
  den.schema.user.includes = [
    userEnrichment
    resolvedUserEmitter
  ];
}
