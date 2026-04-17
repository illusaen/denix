{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.boot ];
  den.aspects.boot = {
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
