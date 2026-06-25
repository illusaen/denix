{rootPath, ...}: {
  den.aspects.programs.zed = {
    wrapper-packages = {host, ...}: {
      zed = {
        imports = [(rootPath + /wrappers/zed/zed.nix)];
        fonts = {
          inherit (host.settings.base.fonts) sans mono icon;
          size = host.settings.base.fonts.sizes.applications;
        };
        scheme = host.settings.base.base16.scheme;
      };
    };

    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.local.zed];};
  };
}
