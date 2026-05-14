{ den, ... }:
{
  den.aspects.nix.includes = with den.aspects.nix; [ boot ];

  den.aspects.nix.boot = {
    nixos = {
      hardware.facter.reportPath = ./facter.json;

      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        initrd.systemd.enable = true;
        zfs.forceImportRoot = false;
      };
    };
  };
}
