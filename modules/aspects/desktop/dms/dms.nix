{ den, inputs, ... }:
{
  flake-file.inputs = {
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell-src = {
      url = "github:quickshell-mirror/quickshell";
      flake = false;
    };
  };

  den.aspects.desktop.includes = [ den.aspects.dms ];
  den.aspects.dms = den.lib.perHost {
    persistUser.directories = [ ".config/DankMaterialShell" ];

    nixos =
      {
        pkgs,
        ...
      }:
      let
        quickshellPackage = pkgs.quickshell.overrideAttrs (_old: {
          src = inputs.quickshell-src.sourceInfo.outPath;
        });
      in
      {
        imports = [
          inputs.dms.nixosModules.dank-material-shell
        ];
        programs.dank-material-shell = {
          enable = true;
          enableVPN = false;
          systemd.enable = true;
          quickshell.package = quickshellPackage;
        };

        environment.systemPackages = with pkgs; [
          adw-gtk3
          adwaita-qt6
          dracula-icon-theme
        ];
      };
  };
}
