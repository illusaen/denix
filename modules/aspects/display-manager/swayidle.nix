{ rootPath, ... }: {
  den.aspects.display-manager.swayidle = {
    wrapper-packages.swayidle = rootPath + /wrappers/swayidle.nix;

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.local.swayidle ];
        systemd.packages = [ pkgs.local.swayidle ];
        systemd.user.services.swayidle.wantedBy = [ "graphical-session.target" ];
        # systemd.user.services.swayidle = {
        #   inherit (service)
        #     after
        #     description
        #     partOf
        #     requires
        #     wantedBy
        #     ;
        #   script = "exec ${lib.getExe pkgs.local.swayidle}";
        #   serviceConfig = lib.removeAttrs service.serviceConfig [ "ExecStart" ];
        # };
      };
  };
}
