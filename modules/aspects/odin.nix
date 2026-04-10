{ den, ... }:
{
  # host aspect
  den.aspects.odin = {
    disko = (import ./boot/_disko.nix { inherit (den.aspects.impermanence) disk persistMount; });

    includes = [
      den.aspects.amd
      den.aspects.nvidia
      den.aspects.desktop
      den.aspects.chat
      den.aspects.gaming
      den.aspects.vscode
    ];
  };
}
