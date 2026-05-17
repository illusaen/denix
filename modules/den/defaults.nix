{
  lib,
  den,
  ...
}:
let
  myLib = import ./_helpers.nix { inherit lib; };
  inherit (myLib) mkSubmoduleOption mkStrOption;
in
{
  den.default = {
    includes = [
      den.batteries.inputs'
      den.batteries.self'
    ];

    nixos.system.stateVersion = "26.05";
    darwin.system.stateVersion = 6;
  };

  den.schema.user = {
    includes = [
      den.batteries.define-user
      (den.batteries.user-shell "fish")
    ];
    classes = lib.mkDefault [ "hjem" ];
  };

  den.schema.host = {
    options = {
      ip = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      preservation = mkSubmoduleOption {
        persistMount = mkStrOption "/persisted";
        disk = mkStrOption "nvme1n1";
        rollbackSnapshot = mkStrOption "zroot/local/root@blank";
      };
    };
  };

  den.schema.host.includes = [
    den.batteries.hostname
    den.aspects.base
  ];
}
