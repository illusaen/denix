{
  den,
  lib,
  inputs,
  ...
}:
let
  persistMount = "/persisted";
  disk = "nvme1n1";
  rollbackSnapshot = "zroot/local/root@blank";
in
{
  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  den.ctx.host.includes = [
    den.aspects.preservation
    den.aspects.find-ephemeral
  ];
  den.aspects.preservation =
    # deadnix: skip
    { config, ... }: # config needs to be here for option vars to work
    {
      includes = lib.attrValues den.aspects.preservation._;
      imports = [
        {
          options = {
            disk = lib.mkOption {
              type = lib.types.str;
              default = disk;
            };
            persistMount = lib.mkOption {
              type = lib.types.str;
              default = persistMount;
            };
            rollbackSnapshot = lib.mkOption {
              type = lib.types.str;
              default = rollbackSnapshot;
            };
          };
        }
      ];

      _.enable = den.lib.perHost {
        nixos =
          { pkgs, ... }:
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

      _.classes =
        let
          # --- Shared Deduplication Module --- #
          # Without this `adapterModule` the `persist`, `persistIgnore`, and user
          # relative classes will duplicate values within their respective lists
          dedupModule = {
            options = {
              directories = lib.mkOption {
                type = with lib.types; listOf anything;
                default = [ ];
                apply = lib.unique;
              };
              files = lib.mkOption {
                type = with lib.types; listOf anything;
                default = [ ];
                apply = lib.unique;
              };
            };
          };
        in
        {
          includes = lib.attrValues den.aspects.preservation._.classes._;

          _.persistedClass = den.lib.perHost (
            { aspect-chain, ... }:
            den._.forward {
              each = lib.singleton true;
              fromClass = _: "persist";
              intoClass = _: "nixos";
              intoPath = _: [
                "preservation"
                "preserveAt"
                persistMount
              ];
              fromAspect = _: lib.head aspect-chain;
              guard = { options, ... }: options ? preservation.preserveAt;
              adapterModule = dedupModule;
            }
          );

          _.persistedUserClass = den.lib.perHost (
            { host }:
            { aspect-chain, ... }:
            den._.forward {
              each = lib.attrNames host.users;
              fromClass = _: "persistUser";
              intoClass = _: "nixos";
              intoPath = userName: [
                "preservation"
                "preserveAt"
                persistMount
                "users"
                userName
              ];
              fromAspect = _: lib.head aspect-chain;
              guard = { options, ... }: options ? preservation.preserveAt;
              adapterModule = dedupModule;
            }
          );
        };

      _.system = den.lib.perHost {
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
          ];
        };
      };
    };
}
