{
  den,
  lib,
  inputs,
  ...
}:
{
  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  den.classes = {
    persist.description = "System persisted directories and files.";
    persistUser.description = "User persisted directories and files.";
  };

  den.policies.persist-to-preservation =
    { host, ... }:
    lib.optional host.preservation.enable (
      den.lib.policy.route {
        fromClass = "persist";
        intoClass = "nixos";
        path = [
          "preservation"
          "preserveAt"
          host.preservation.persistMount
        ];
        guard = { options, ... }: options ? preservation.preserveAt;
      }
    );

  den.policies.persist-user-to-preservation =
    {
      host,
      user,
      ...
    }:
    lib.optional host.preservation.enable (
      den.lib.policy.route {
        fromClass = "persistUser";
        intoClass = "nixos";
        path = [
          "preservation"
          "preserveAt"
          host.preservation.persistMount
          "users"
          user.userName
        ];
        guard = { options, ... }: options ? preservation.preserveAt;
      }
    );

  den.schema.host.includes = [ den.policies.persist-to-preservation ];
  den.schema.user.includes = [ den.policies.persist-user-to-preservation ];

  den.aspects.boot.preservation = {
    includes = [ den.aspects.boot.preservation.find-ephemeral ];

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

    provides.to-users.persistUser = {
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

    nixos =
      {
        pkgs,
        host,
        ...
      }:
      let
        inherit (host.preservation) persistMount rollbackSnapshot;
      in
      {
        imports = [ inputs.preservation.nixosModules.preservation ];

        preservation.enable = true;

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

        networking.hostId = "17888962";
        fileSystems."${persistMount}".neededForBoot = true;
      };
  };
}
