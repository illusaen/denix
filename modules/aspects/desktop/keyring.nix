{ den, lib, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.keyring ];

  den.aspects.keyring = {
    includes = lib.attrValues den.aspects.keyring._;

    _.gnome-keyring = {
      nixos =
        { config, lib, ... }:
        {
          services.gnome.gnome-keyring.enable = lib.mkDefault true;
          programs.seahorse.enable = lib.mkDefault true;

          xdg.portal.config.common = lib.mkIf config.services.gnome.gnome-keyring.enable {
            "org.freedesktop.impl.portal.Secret" = lib.mkDefault [ "gnome-keyring" ];
          };
        };
    };

    _.polkit-gnome = {
      nixos =
        { lib, ... }:
        {
          security.polkit.enable = lib.mkDefault true;
        };

      hm =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {
          services.polkit-gnome.enable = lib.mkDefault true;

          systemd.user.services = lib.mkIf config.services.polkit-gnome.enable {
            polkit-gnome-authentication-agent-1 = lib.mkDefault {
              Unit = {
                Description = "polkit-gnome-authentication-agent-1";
                Wants = [ "graphical-session.target" ];
                After = [ "graphical-session.target" ];
              };
              Install = {
                WantedBy = [ "graphical-session.target" ];
              };
              Service = {
                Type = "simple";
                ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
                Restart = "on-failure";
                RestartSec = 1;
                TimeoutStopSec = 10;
              };
            };
          };
        };
    };
  };
}
