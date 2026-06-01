{
  den,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  den.aspects.wm.includes = with den.aspects.wm; [ dms ];

  den.aspects.wm.dms = {
    provides.to-users.persistUser.directories = [
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

    provides.to-users.hjemLinux =
      {
        pkgs,
        lib,
        fleet,
        ...
      }:
      {
        xdg.config.files."DankMaterialShell/themes/custom/theme.json".source = fleet.my.scheme.render {
          inherit pkgs lib;
          template = ./dms-theme.json.mustache;
          extension = "json";
        };
      };
  };
}
