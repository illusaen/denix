{ den, ... }:
{
  den.aspects.boot = {
    includes = with den.aspects.boot; [
      preservation
      disko
      facter
    ];
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
