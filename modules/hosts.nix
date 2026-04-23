{ den, ... }:
let
  disko = import ./aspects/boot/_disko.nix {
    inherit (den.aspects.preservation) disk persistMount rollbackSnapshot;
  };
in
{
  den.hosts.x86_64-linux.odin.users.wendy = { };
  den.hosts.x86_64-linux.thor.users.wendy = { }; # Seedbox server
  den.hosts.aarch64-darwin.idunn.users.wendy = { };

  # host aspect
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
    ];
  };

  den.aspects.thor = {
    inherit disko;
  };

  den.aspects.idunn = {
    includes = with den.aspects; [
      vscode
      darwinConfig
      element
      discord
    ];
  };

  # user aspect
  den.aspects.wendy = {
    includes = [
      den.provides.primary-user
    ]
    ++ (with den.aspects; [
      vscode
      element
      discord
      steam
      desktop
    ]);

    user.password = "arst";

    persistUser.directories = [
      "Downloads"
      "Projects"
      "Pictures"
    ];
  };
}
