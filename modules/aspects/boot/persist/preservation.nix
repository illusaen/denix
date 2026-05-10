{
  den,
  lib,
  inputs,
  helpers,
  ...
}:
let
  persistMount = "/persisted";
  disk = "nvme1n1";
  rollbackSnapshot = "zroot/local/root@blank";

  mergeFn =
    class: _:
    let
      inherit (den.lib.policy) pipe;
    in
    [
      (pipe.from class [
        (pipe.fold helpers.mergeModule { })
      ])
    ];
in
{
  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  den.quirks = {
    persist.description = "System persisted directories and files.";
    persistUser.description = "User persisted directories and files.";
  };

  den.policies.merge-persist = mergeFn "persist";
  den.policies.merge-persist-user = mergeFn "persistUser";

  den.schema.host.includes = [
    den.aspects.preservation
    den.aspects.find-ephemeral
    den.policies.merge-persist
    den.policies.merge-persist-user
  ];

  den.aspects.preservation = {
    meta.vars = {
      inherit disk persistMount rollbackSnapshot;
    };

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

    nixos =
      {
        host,
        pkgs,
        persist,
        persistUser,
        ...
      }:
      {
        imports = [ inputs.preservation.nixosModules.preservation ];

        preservation.enable = true;
        preservation.preserveAt.${persistMount} = (lib.head persist) // {
          users = lib.mapAttrs (_: _: lib.head persistUser) host.users;
        };

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
