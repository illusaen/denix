{ den, ... }:
{
  flake-file.inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.desktop.includes = [ den.aspects.dms ];
  den.aspects.dms = den.lib.perHost {
    nixos =
      { inputs', ... }:
      {
        programs.dms-shell = {
          enable = true;
          package = inputs'.dms.packages.default;
          quickshell.package = inputs'.quickshell.packages.quickshell;

          enableVPN = false;
        };
      };
  };
}
