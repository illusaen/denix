{ den, inputs, ... }:
{
  flake-file.inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
    quickshell = {
      url = "github:illusaen/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.desktop._.dms = den.lib.perHost {
    persistUser.directories = [
      ".config/DankMaterialShell"
      ".config/niri/dms"
      ".cache/DankMaterialShell"
      ".local/state/DankMaterialShell"
    ];

    nixos = {
      imports = [ inputs.dms.nixosModules.dank-material-shell ];
      programs.dank-material-shell = {
        enable = true;
        enableVPN = false;
        systemd.enable = true;
      };

      security.pam.u2f.enable = true;
    };

    hj = {
      xdg.config.files."DankMaterialShell/themes/custom/theme.json".source = ./dms-theme.json;
    };
  };
}
