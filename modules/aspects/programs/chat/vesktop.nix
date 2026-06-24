{rootPath, ...}: {
  den.aspects.programs.chat.vesktop = {
    wrapper-packages = {host, ...}: {
      vesktop-base16 = {
        imports = [(rootPath + /wrappers/vesktop/vesktop.nix)];
        instanceName = "base16";
        fonts = host.settings.base.fonts;
        colors = host.settings.base.base16.scheme.withHashtag;
      };
    };

    os = {pkgs, ...}: {
      environment.systemPackages = [pkgs.local.vesktop-base16];
    };

    nixos = {pkgs, ...}: {
      environment.etc."packages/vesktop/base16".source = "${pkgs.local.vesktop-base16}/defaults";
      systemd.packages = [pkgs.local.vesktop-base16];
      systemd.user.services.vesktop-base16.wantedBy = ["graphical-session.target"];
    };
  };
}
