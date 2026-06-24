{rootPath, ...}: {
  den.aspects.display-manager.niri = {
    wrapper-packages = {host, ...}: {
      niri = let
        theming = host.settings.theming;
        base16 = host.settings.base.base16;
        monitors = host.settings."display-manager".monitor;
      in {
        imports = [(rootPath + /wrappers/niri/niri.nix)];
        monitors = {
          main = monitors.main.desc;
          secondary = monitors.secondary.desc;
        };
        cursor = {
          inherit (theming.cursorTheme) name size;
        };
        colors = base16.scheme.withHashtag;
      };
      niri-scripts = rootPath + /wrappers/custom-scripts/niri-scripts.nix;
    };

    nixos = {pkgs, ...}: {
      nix.settings = {
        substituters = ["https://niri.cachix.org"];
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
        local.niri-scripts
        xwayland-satellite
      ];
    };
  };
}
