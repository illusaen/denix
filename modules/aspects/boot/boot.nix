{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.boot ];
  den.aspects.boot = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        boot = {
          kernelPackages = pkgs.linuxPackages_latest;

          loader.systemd-boot.enable = true;
          loader.efi.canTouchEfiVariables = true;
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
        };
      };
  };
}
