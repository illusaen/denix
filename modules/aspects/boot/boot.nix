{ den, ... }:
{
  den.schema.host.includes = [ den.aspects.boot ];
  den.aspects.boot = {
    nixos = {
      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        initrd.systemd.enable = true;

        supportedFilesystems = [
          "cifs"
        ];

        initrd.availableKernelModules = [
          "nvme"
          "ahci"
          "xhci_pci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];

        zfs.forceImportRoot = false;

        kernelParams = [ "usbcore.autosuspend=-1" ];
      };
    };
  };
}
