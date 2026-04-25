{ den, ... }:
let
  disko = import ../aspects/boot/_disko.nix {
    inherit (den.aspects.preservation.meta.vars) disk persistMount rollbackSnapshot;
  };
in
{
  den.hosts.x86_64-linux.odin = {
    users.wendy = { };
    ip = "192.168.1.163";
  };
  den.hosts.x86_64-linux.thor = {
    users.wendy = { };
    ip = "192.168.1.164";
  };
  den.hosts.x86_64-linux.fenrir = {
    users.wendy = { };
    ip = "192.168.1.164";
  };
  den.hosts.aarch64-darwin.idunn.users.wendy = { };

  # Main PC
  den.aspects.odin = {
    inherit disko;

    includes = with den.aspects; [
      amd
      nvidia
      desktop
      steam
      vscode
      element
      discord
      fonts
    ];

    # `desktop` has both host and user subaspects
    _.to-users.includes = [ den.aspects.desktop ];
  };

  # Seedbox server
  den.aspects.thor = {
    inherit disko;

    includes = with den.aspects; [
      fonts
      server
    ];
  };

  # Macbook
  den.aspects.idunn = {
    includes = with den.aspects; [
      vscode
      darwinConfig
      element
      discord
      fonts
    ];
  };

  # Bootable ISO
  den.aspects.fenrir = {
    includes = with den.aspects; [
      fonts
      server
    ];

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

  # Common user
  den.aspects.wendy = {
    includes = [ den.provides.primary-user ];

    user.password = "arst";

    persistUser.directories = [
      "Downloads"
      "Projects"
      "Pictures"
    ];
  };
}
