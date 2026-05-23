{ self, ... }:
{
  den.aspects.iso = {
    nixos =
      {
        modulesPath,
        config,
        lib,
        ...
      }:
      let
        inherit (self.my.vars) userName;
      in
      {
        imports = [
          "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix"
        ];

        ## IMPORTANT! using `wendy` as main user
        lib.isoFileSystems."/home/${userName}" = {
          device = "/dev/disk/by-label/${userName}";
          fsType = "ext4";
        };

        users.users.wendy.uid = 1000;
        users.users.nixos.uid = 1001;

        isoImage.edition = lib.mkDefault config.networking.hostName;
        networking.wireless.enable = lib.mkImageMediaOverride false;
      };
  };
}
