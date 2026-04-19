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
  flake-file.inputs.impermanence.url = "github:nix-community/impermanence";

  den.ctx.host.includes = [
    den.aspects.impermanence
    den.aspects.impermanence._.persistedClass
    den.aspects.impermanence._.persistedUserClass
  ];

  den.aspects.impermanence =
    # deadnix: skip
    { config, ... }: # config needs to be here for option vars to work
    {
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

      _.persistedClass =
        { host }:
        { aspect-chain, ... }:
        den._.forward {
          each = lib.attrNames host.users;
          fromClass = _: "persist";
          intoClass = _: "nixos";
          intoPath = _: [
            "environment"
            "persistence"
            persistMount
          ];
          fromAspect = _: lib.head aspect-chain;
          guard = { options, ... }: options ? environment.persistence;
        };

      _.persistedUserClass =
        { host }:
        { aspect-chain, ... }:
        den._.forward {
          each = lib.attrNames host.users;
          fromClass = _: "persistUser";
          intoClass = _: "nixos";
          intoPath = userName: [
            "environment"
            "persistence"
            persistMount
            "users"
            userName
          ];
          fromAspect = _: lib.head aspect-chain;
          guard = { options, ... }: options ? environment.persistence;
        };

      nixos =
        { pkgs, ... }:
        {
          imports = [
            inputs.impermanence.nixosModules.impermanence
          ];

          boot.initrd.systemd.services.zfs-rollback = {
            description = "Rollback ZFS root dataset to blank snapshot";
            wantedBy = [
              "initrd.target"
            ];
            after = [
              # this is a dynamically generated service, based on the zpool name
              "zfs-import-zpool.service"
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

          networking.hostId = "17888962";
          fileSystems."${persistMount}".neededForBoot = true;
          environment.etc."machine-id".text = "17888962e0404e3980b23115d2d91984";
        };

      persist = {
        hideMounts = true;
        allowTrash = true;

        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
        ];
      };

      persistUser.directories = [
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
      ];
    };
}
