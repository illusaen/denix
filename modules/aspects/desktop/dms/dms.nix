{ inputs, ... }:
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

  den.aspects.desktop._.dms = {
    persistUser.directories = [
      ".config/DankMaterialShell"
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

    hj =
      { config, ... }:
      {
        xdg.config.files."DankMaterialShell/themes/custom/theme.json".source = config.scheme {
          template = ./dms-theme.json.mustache;
          extension = "json";
        };
      };
  };
}
