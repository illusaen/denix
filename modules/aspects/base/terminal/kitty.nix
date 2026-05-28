{
  den.aspects.base.terminal.kitty =
    { self, ... }:
    {
      nixos =
        { self', ... }:
        {
          environment.systemPackages = [
            self'.packages.kitty
          ];
        };

      wrapper-packages.kitty =
        let
          inherit (self.my) fonts;
        in
        {
          imports = [ ../../../wrappers/kitty/kitty.nix ];
          font = {
            name = fonts.mono;
            size = fonts.sizes.terminal;
          };
        };
    };
}
