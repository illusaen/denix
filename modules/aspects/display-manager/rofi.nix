{ rootPath, ... }: {
  den.aspects.display-manager.rofi = {
    wrapper-packages = { fleet, ... }: {
      rofi =
        let
          font = fleet.my.fonts.sans;
          icon = fleet.my.theming.iconTheme.name;
          colors = fleet.my.base16.scheme.withHashtag;
        in
        {
          imports = [ (rootPath + /wrappers/rofi/rofi.nix) ];
          inherit font icon colors;
        };
    };

    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.local.rofi ];
    };
  };
}
