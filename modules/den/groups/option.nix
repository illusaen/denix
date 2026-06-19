# Group registry.
#
# Groups are data-only (no isEntity) — they don't get resolved into the
# scope tree. Group data is consumed directly by user access policies
# and scope-engine ACL resolution.
{
  lib,
  ...
}:
{
  options.den.groups =
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        listOf
        nullOr
        str
        submodule
        int
        attrsOf
        ;
      groupType = submodule {
        options = {
          labels = mkOption {
            type = listOf str;
            default = [ ];
            description = "Classification labels for the group (e.g., posix, oauth-grant, user-role)";
          };

          description = mkOption {
            type = str;
            default = "";
            description = "Human-readable description of the group";
          };

          members = mkOption {
            type = listOf str;
            default = [ ];
            description = "Other groups whose members inherit membership in this group";
          };

          gid = mkOption {
            type = nullOr int;
            default = null;
            description = "POSIX group ID number (required for groups with the 'posix' label)";
          };
        };
      };
    in
    lib.mkOption {
      type = attrsOf groupType;
      default = { };
      description = "Group definitions for access policy resolution";
    };
}
