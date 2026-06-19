{ rootPath, ... }: {
  den.aspects.base.terminal.foot = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.local.foot ];
      systemd.packages = [ pkgs.local.foot ];
      systemd.user.services.foot = {
        wantedBy = [ "graphical-session.target" ];
        path = [
          "/run/wrappers"
          "/run/current-system/sw"
        ];
      };
    };

    wrapper-packages = { fleet, ... }: {
      foot =
        let
          inherit (fleet.my) fonts base16;
        in
        {
          imports = [ (rootPath + /wrappers/foot.nix) ];
          colors = base16.scheme;
          font = {
            name = fonts.mono;
            size = fonts.sizes.terminal;
          };
        };
    };
  };
}
