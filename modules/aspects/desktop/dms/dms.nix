{ den, inputs, ... }:
{
  flake-file.inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
    quickshell = {
      url = "github:quickshell-mirror/quickshell/staging";
      flake = false;
    };
  };

  den.aspects.desktop.includes = [ den.aspects.dms ];
  den.aspects.dms = den.lib.perHost {
    persistUser.directories = [
      ".config/DankMaterialShell"
      ".config/niri/dms"
    ];

    nixos =
      {
        ...
      }:
      {
        imports = [
          inputs.dms.nixosModules.dank-material-shell
        ];
        programs.dank-material-shell = {
          enable = true;
          enableVPN = false;
          systemd.enable = true;
          # quickshell.package = quickshellPackage;
        };

        security.pam.u2f.enable = true;
      };
  };
}
