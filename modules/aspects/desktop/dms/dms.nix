{ den, ... }:
{
  flake-file.inputs = {
    # dms = {
    #   url = "github:AvengeMedia/DankMaterialShell/stable";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # quickshell.url = "github:quickshell-mirror/quickshell/master";
    # quickshell-src = {
    #   url = "github:quickshell-mirror/quickshell/master";
    #   flake = false;
    # };
  };

  den.aspects.desktop.includes = [ den.aspects.dms ];
  den.aspects.dms = den.lib.perHost {
    persistUser.directories = [
      ".config/DankMaterialShell"
      ".config/niri/dms"
    ];

    nixos =
      _:
      # let
      #   quickshellPackage = pkgs.quickshell.overrideAttrs (_old: {
      #     src = inputs.quickshell-src.sourceInfo.outPath;
      #     version = "0.3.0";
      #   });
      # in
      {
        # imports = [
        #   inputs.dms.nixosModules.dank-material-shell
        # ];
        programs.dms-shell = {
          enable = true;
          enableVPN = false;
          # systemd.enable = true;
          # quickshell.package = quickshellPackage;
        };

        security.pam.u2f.enable = true;
      };
  };
}
