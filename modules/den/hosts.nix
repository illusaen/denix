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
    roles = [ "desktop" ];
  };
  den.hosts.x86_64-linux.thor = {
    users.wendy = { };
    ip = "192.168.1.164";
    roles = [
      "server"
      "iso"
    ];
  };
  den.hosts.aarch64-darwin.idunn = {
    users.wendy = { };
    roles = [ "desktop" ];
  };

  # Main PC
  den.aspects.odin = {
    inherit disko;

    includes = with den.aspects; [
      amd
      nvidia
      desktop
      steam
      element
      discord
      theming
      word
      bambu-studio
      vscode
    ];

    # `theming` has both host and user subaspects
    _.to-users.includes = [
      den.aspects.theming
    ];
  };

  # Seedbox server and Bootable ISO
  den.aspects.thor = {
    inherit disko;

    includes = with den.aspects; [
      server
      iso
    ];
  };

  # Macbook
  den.aspects.idunn = {
    includes = with den.aspects; [
      element
      discord
      paneru
      word
    ];
  };

  # Common user
  den.aspects.wendy = {
    includes = [ den.batteries.primary-user ];
    user.password = "arst";
  };
}
