{ rootPath, ... }: {
  den.aspects.display-manager.swayidle = {
    wrapper-packages = {
      swayidle = {
        imports = [ (rootPath + /wrappers/swayidle.nix) ];
      };
    };

    nixos = { self', lib, ... }: {
      environment.systemPackages = [ self'.packages.swayidle ];

      systemd.user.services.swayidle = {
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        requires = [ "graphical-session-pre.target" ];
        after = [
          "graphical-session.target"
          "graphical-session-pre.target"
        ];
        description = "swayidle for monitor power on and off";
        script = lib.getExe self'.packages.swayidle;
      };
    };
  };
}
