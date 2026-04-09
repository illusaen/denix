{ den, ... }:
{
  # host aspect
  den.aspects.odin = {
    disko = (import ./boot/_disko.nix { inherit (den.aspects.impermanence) disk persistMount; });

    includes = with den.aspects; [
      amd
      nvidia
    ];
  };
}
