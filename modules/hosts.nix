{ den, ... }:
{
  den.hosts.x86_64-linux.odin.users.wendy = { };
  den.hosts.x86_64-linux.thor.users.wendy = { }; # Seedbox server
  den.hosts.aarch64-darwin.idunn.users.wendy = { };

  # host aspect
  den.aspects.odin = {
    disko = (import ./boot/_disko.nix { inherit (den.aspects.impermanence) disk persistMount; });

    includes = with den.aspects; [
      amd
      nvidia
      desktop
      chat
      gaming
      vscode
    ];
  };

  den.aspects.idunn = {
    includes = with den.aspects; [
      chat
      vscode
      darwinConfig
    ];
  };

  # user aspect
  den.aspects.wendy = {
    includes = [
      den.provides.primary-user
    ];

    user.password = "arst";

    persistUser.directories = [
      "Downloads"
      "Projects"
      "Pictures"
    ];
  };
}
