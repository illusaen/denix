{
  lib,
  den,
  inputs,
  config,
  ...
}:
let
  schemaLib = inputs.gen-schema.lib;
in
{
  options.den.genSchema = schemaLib.mkSchemaOption { };

  config.den.genSchema.environment = {
    imports = den.schema.environment.imports or [ ];
    methods = den.schema.environment.methods or { };
    options.aspect = lib.mkOption {
      type = lib.types.raw;
      default = { };
      description = "Aspect that configures this environment";
    };
  };

  options.den.environments = schemaLib.mkInstanceRegistry config.den.genSchema.environment {
    strict = false;
    description = "Environment definitions for fleet topology and service resolution";
  };
}
