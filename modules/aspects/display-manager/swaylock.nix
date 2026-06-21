{rootPath, ...}: {
  den.aspects.display-manager.swaylock = {
    wrapper-packages = {fleet, ...}: {
      swaylock = let
        inherit (fleet.my) base16 fonts wallpaper;
      in {
        imports = [(rootPath + /wrappers/swaylock.nix)];
        font = fonts.sans;
        colors = base16.scheme;
        image = wallpaper;
      };
    };

    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.local.swaylock];};
  };
}
