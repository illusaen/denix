{
  den,
  inputs,
  self,
  ...
}:
{
  flake-file.inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
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

    provides.to-users.hjem =
      { pkgs, lib, ... }:
      {
        xdg.config.files."DankMaterialShell/themes/custom/theme.json".source = self.my.scheme.render {
          inherit pkgs lib;
          template = ./dms-theme.json.mustache;
          extension = "json";
        };
      };
  };
}
