{ rootPath, ... }:
{
  den.aspects.base.terminal.kitty = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.local.kitty
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
