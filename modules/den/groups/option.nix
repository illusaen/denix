# Group registry.
#
# Groups are data-only (no isEntity) — they don't get resolved into the
# scope tree. Group data is consumed directly by user access policies
# and scope-engine ACL resolution.
{
  config,
  den,
  inputs,
  ...
}: let
  schemaLib = inputs.gen-schema.lib;
in {
  config.den.genSchema.group = {
    imports = den.schema.group.imports or [];
    validators = den.schema.group.validators or [];
  };

  options.den.groups = schemaLib.mkInstanceRegistry config.den.genSchema.group {
    strict = false;
    description = "Group definitions for access policy resolution";
  };
}
