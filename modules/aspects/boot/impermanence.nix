{
  den,
  lib,
  inputs,
  ...
}:
let
  persistMount = "/persisted";
  disk = "nvme1n1";
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
            };
            persistMount = lib.mkOption {
              type = lib.types.str;
            };
          };
        }
      ];
      inherit persistMount disk;

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

      nixos = {
        imports = [
          inputs.impermanence.nixosModules.impermanence
        ];

        boot.initrd.postResumeCommands = lib.mkAfter ''
          zfs rollback -r zroot/local/root@blank
        '';
        networking.hostId = "17888962";
        fileSystems."${persistMount}".neededForBoot = true;
        environment.etc."machine-id".text = "17888962e0404e3980b23115d2d91984";
      };

      persist.directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
      ];
      persistUser.directories = [
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
      ];
    };
}
