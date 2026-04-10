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
    # den.aspects.impermanence._.persysClass
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

      # _.persysClass = (
      #   { host }:
      #   den._.forward {
      #     each = lib.singleton true;
      #     fromClass = _: "persys";
      #     intoClass = _: "nixos";
      #     intoPath = _: [
      #       "environment"
      #       "persistence"
      #       persistMount
      #     ];
      #     fromAspect = _: den.aspects.${host.aspect};
      #     guard = { options, ... }: options ? environment.persistence;
      #   }
      # );

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

      nixos.environment.persistence.${persistMount} = {
        directories = [
          "/var/log"
          {
            directory = "/var/lib/bluetooth";
            mode = "0755";
          }
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/var/lib/tailscale"
          "/var/lib/flatpak"
          "/var/lib/gdm"
          "/etc/NetworkManager/system-connections"
        ];
        files = [
          {
            file = "/etc/opnix-token";
            parentDirectory = {
              mode = "0755";
            };
          }
        ];
        users.wendy = {
          directories = [
            "Downloads"
            "Projects"
            {
              directory = ".local/share/keyrings";
              mode = "0700";
            }
            ".config/1Password"
            {
              directory = ".config/op";
              mode = "0700";
            }
            ".cache/flatpak"
            ".config/Code"
            ".config/google-chrome"
            ".config/gh"
            ".config/vesktop"
            ".local/share/direnv"
            ".local/share/zoxide"
            ".local/share/fish"
            ".local/share/flatpak"
            ".local/share/Steam"
            ".ssh"
            ".var/app/com.bambulab.BambuStudio"
          ];
        };
      };
    };
}
