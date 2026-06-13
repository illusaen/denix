{ rootPath, ... }: {
  den.aspects.display-manager.rofi = {
    wrapper-packages =
      { fleet, ... }:
      let
        font = fleet.my.fonts.sans;
        icon = fleet.my.theming.iconTheme.name;
        colors = fleet.my.base16.scheme.withHashtag;
        wrapper = rootPath + /wrappers/rofi/rofi.nix;
      in
      {
        rofi = {
          imports = [ wrapper ];
          inherit font icon colors;
        };
      };

    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs.local; [ rofi ];
    };
  };
}
