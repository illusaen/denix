{ rootPath, ... }:
{
  den.aspects.display-manager.niri = {
    wrapper-packages =
      { fleet, ... }:
      {
        niri =
          let
            inherit (fleet.my) theming base16;
          in
          {
            imports = [ (rootPath + /wrappers/niri/niri.nix) ];
            monitor = {
              main = "LG Electronics LG ULTRAGEAR+ 508RMWVJR505";
              secondary = "BOE Display 000000001";
            };
            cursor = {
              inherit (theming.cursorTheme) name size;
            };
            highlightColor = base16.scheme.withHashtag.base0E;
          };
      };

    nixos =
      { pkgs, self', ... }:
      {
        nix.settings = {
          substituters = [ "https://niri.cachix.org" ];
          trusted-public-keys = [
            "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
          ];
        };

        programs.niri = {
          enable = true;
          package = self'.packages.niri;
          useNautilus = true;
        };

        environment.systemPackages = with pkgs; [
          xwayland-satellite
        ];
      };
  };
}
