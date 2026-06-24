{rootPath, ...}: {
  den.aspects.display-manager.rofi = {
    wrapper-packages = {host, ...}: let
      font = host.settings.base.fonts.sans;
      icon = host.settings.theming.iconTheme.name;
      colors = host.settings.base.base16.scheme.withHashtag;
      wrapper = rootPath + /wrappers/rofi/rofi.nix;
    in {
      rofi = {
        imports = [wrapper];
        inherit
          font
          icon
          colors
          ;
      };
      rofi-scripts = rootPath + /wrappers/custom-scripts/rofi-scripts.nix;
    };

    nixos = {pkgs, ...}: {environment.systemPackages = with pkgs.local; [rofi rofi-scripts];};
  };
}
