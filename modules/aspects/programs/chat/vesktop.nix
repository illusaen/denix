{ rootPath, ... }:
{
  den.aspects.programs.chat.vesktop = {
    wrapper-packages =
      { fleet, ... }:
      {
        vesktop-base16 = {
          imports = [ (rootPath + /wrappers/vesktop/vesktop.nix) ];
          instanceName = "base16";
          inherit (fleet.my) fonts;
          colors = fleet.my.base16.scheme.withHashtag;
        };
      };

    os =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.local.vesktop-base16 ];
      };

    nixos =
      { pkgs, ... }:
      {
        environment.etc."packages/vesktop/base16".source = "${pkgs.local.vesktop-base16}/defaults";
        systemd.packages = [ pkgs.local.vesktop-base16 ];
        systemd.user.services.vesktop-base16.wantedBy = [ "graphical-session.target" ];
      };
  };
}
