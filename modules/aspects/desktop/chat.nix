{ den, ... }:
{
  den.aspects.desktop.includes = with den.aspects.desktop; [ chat ];

  den.aspects.desktop.chat = {
    provides.to-users.persistUser.directories = [
      ".config/discord"
      ".config/Element"
    ];

    os =
      { pkgs, ... }:
      {
        nixpkgs.overlays = [
          (_: prev: {
            discord = prev.discord.override { withOpenASAR = true; };
            element-desktop = prev.element-desktop.overrideAttrs (old: {
              postFixup = (old.postFixup or "") + ''
                sed -i 's|^Exec=\([^ ]*\) .*|Exec=\1 --password-store="gnome-libsecret"|' \
                  $out/share/applications/element-desktop.desktop
              '';
            });
          })
        ];
        environment.systemPackages = with pkgs; [
          discord
          element-desktop
        ];
      };

    nixos =
      { pkgs, ... }:
      {
        systemd.user.services.discord-start = {
          description = "Start discord on login";
          after = [
            "graphical-session.target"
            "graphical-session-pre.target"
          ];
          wantedBy = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
            ExecStart = "${pkgs.discord}/bin/discord";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      };
  };
}
