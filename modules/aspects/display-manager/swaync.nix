{ rootPath, ... }: {
  den.aspects.display-manager.swaync = {
    wrapper-packages =
      { fleet, ... }:
      {
        swaync =
          let
            inherit (fleet.my) fonts base16;
          in
          {
            imports = [ (rootPath + /wrappers/swaync/swaync.nix) ];
            font = fonts.sans;
            colors = base16.scheme.withHashtag;
          };
      };

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs.local; [ swaync ];
        systemd.packages = [ pkgs.local.swaync ];
      };
  };
}
