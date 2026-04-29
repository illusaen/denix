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
      theming
    ];

    # `theming` has both host and user subaspects
    _.to-users.includes = [
      den.aspects.theming
    ];
  };

  # Seedbox server
  den.aspects.thor = {
    inherit disko;

    includes = with den.aspects; [
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
      paneru
    ];
  };

  # Bootable ISO
  # nix build .#nixosConfigurations.fenrir.config.system.build.isoImage
  den.aspects.fenrir = {
    includes = with den.aspects; [
      server
      iso
    ];

    # IMPORTANT! ISO uses `wendy` as main user
  };

  # Common user
  den.aspects.wendy =
    { user, ... }:
    {
      includes = [ den.provides.primary-user ];

      nixos.users.users.${user.name}.password = "arst";

      persistUser.directories = [
        "Downloads"
        "Projects"
        "Pictures"
      ];
    };
}
