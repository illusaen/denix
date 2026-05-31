{
  den.aspects.base.terminal.kitty =

    {
      nixos =
        { self', ... }:
        {
          environment.systemPackages = [
            self'.packages.kitty
          ];
        };

      wrapper-packages =
        { fleet, ... }:
        {
          kitty =
            let
              inherit (fleet.my) fonts scheme;
            in
            {
              imports = [ ../../../../wrappers/kitty/kitty.nix ];
              renderScheme = scheme.render;
              font = {
                name = fonts.mono;
                size = fonts.sizes.terminal;
              };
            };
        };
    };
}
