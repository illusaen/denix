{ inputs, ... }:
{
  flake-file.inputs.dms = {
    url = "github:AvengeMedia/DankMaterialShell";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.display-manager.dms = {
    nixos = {
      imports = [ inputs.dms.nixosModules.dank-material-shell ];
      programs.dank-material-shell = {
        enable = false;
        enableVPN = false;
        systemd.enable = false;
      };

      security.pam.u2f.enable = true;
    };

  };
}
