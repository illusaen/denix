{ rootPath, ... }:
{
  den.aspects.base.terminal.kitty = {
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
            inherit (fleet.my) fonts base16;
          in
          {
            imports = [ (rootPath + /wrappers/kitty/kitty.nix) ];
            renderScheme = base16.scheme.render;
            font = {
              name = fonts.mono;
              size = fonts.sizes.terminal;
            };
          };
      };
  };
}
