{ rootPath, ... }: {
  den.aspects.display-manager.swayidle = {
    wrapper-packages.swayidle = rootPath + /wrappers/swayidle.nix;

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.local.swayidle ];
        systemd.packages = [ pkgs.local.swayidle ];
      };
  };
}
