{ den, ... }:
{
  den.aspects.iso = den.lib.perHost {
    nixos =
      {
        modulesPath,
        config,
        lib,
        ...
      }:
      {
        imports = [
          "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix"
        ];

        ## IMPORTANT! using `wendy` as main user
        lib.isoFileSystems."/home/wendy" = {
          device = "/dev/disk/by-label/wendy";
          fsType = "ext4";
        };

        users.users.wendy.uid = 1000;
        users.users.nixos.uid = 1001;

        isoImage.edition = lib.mkDefault config.networking.hostName;
        networking.wireless.enable = lib.mkImageMediaOverride false;
      };
  };
}
