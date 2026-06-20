{ rootPath, ... }:
{
  den.aspects.display-manager.niri = {
    wrapper-packages =
      { fleet, ... }:
      {
        niri =
          let
            inherit (fleet.my) theming base16 monitors;
          in
          {
            imports = [ (rootPath + /wrappers/niri/niri.nix) ];
            monitors = monitors.descriptions;
            cursor = {
              inherit (theming.cursorTheme) name size;
            };
            highlightColor = base16.scheme.withHashtag.base0E;
          };
      };

    nixos =
      { pkgs, ... }:
      {
        nix.settings = {
          substituters = [ "https://niri.cachix.org" ];
          trusted-public-keys = [
            "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
          ];
        };

        programs.niri = {
          enable = true;
          package = pkgs.local.niri;
          useNautilus = true;
        };

        environment.systemPackages = with pkgs; [
          xwayland-satellite
        ];
      };
  };
}
