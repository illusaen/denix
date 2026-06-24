{
  den,
  lib,
  inputs,
  rootPath,
  ...
}: {
  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  den.aspects.boot.preservation = let
    mergePersist = entries: {
      directories = lib.unique (lib.concatMap (e: e.directories or []) entries);
      files = lib.unique (lib.concatMap (e: e.files or []) entries);
    };
  in {
    includes = [den.aspects.boot.preservation.find-ephemeral];

    persist = {
      directories = [
        "/var/log"
        "/var/lib/systemd/timers"
        "/var/lib/systemd/rfkill"
        "/var/lib/systemd/coredump"
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
      ];
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
      ];
    };

    wrapper-packages.preservation-scripts = rootPath + /wrappers/custom-scripts/preservation-scripts.nix;

    provides.to-users = {
      persistUser = {
        commonMountOptions = [
          "x-gvfs-hide"
          "x-gvfs-trash"
        ];
        directories = [
          {
            directory = ".local/share/keyrings";
            mode = "0700";
          }
          "Downloads"
          "Projects"
          "Pictures"
        ];
      };

      nixos = {
        host,
        user,
        persistUser,
        ...
      }: {
        preservation.preserveAt.${host.preservation.persistMount}.users.${user.userName} = mergePersist persistUser;
      };
    };

    nixos = {
      pkgs,
      host,
      persist,
      ...
    }: let
      inherit (host.preservation) persistMount rollbackSnapshot;
    in {
      imports = [inputs.preservation.nixosModules.preservation];

      preservation = {
        enable = true;
        preserveAt.${persistMount} = mergePersist persist;
      };

      environment.systemPackages = [pkgs.local.preservation-scripts];

      boot.initrd.systemd.services.zfs-rollback = {
        description = "Rollback ZFS root dataset to blank snapshot";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          # this is a dynamically generated service, based on the zpool name
          "zfs-import-zroot.service"
        ];
        before = [
          "sysroot.mount"
        ];
        path = with pkgs; [
          zfs
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r ${rollbackSnapshot} && echo "zfs rollback complete"
        '';
      };

      systemd.services.systemd-machine-id-commit = lib.mkDefault {
        # Ensure service will only run if the persistent storage is mounted
        unitConfig.ConditionPathIsMountPoint = [
          ""
          persistMount
        ];
        # Ensure service commits the ID to the persistent volume
        serviceConfig.ExecStart = [
          ""
          "${pkgs.systemd}/bin/systemd-machine-id-setup --commit --root ${persistMount}"
        ];
      };

      fileSystems."${persistMount}".neededForBoot = true;
    };
  };
}
