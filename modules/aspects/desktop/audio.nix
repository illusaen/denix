{
  den.aspects.wm.audio = {
    nixos =
      { pkgs, lib, ... }:
      {
        environment.systemPackages = with pkgs; [
          pavucontrol
          (mpv.override {
            scripts = [
              mpvScripts.uosc
              mpvScripts.sponsorblock
              mpvScripts.mpris
            ];
          })
        ];
        services = {
          pulseaudio.enable = false;
          playerctld.enable = true;

          pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
            wireplumber.enable = true;
          };
        };
        security.rtkit.enable = true;

        environment.etc = lib.mkIf pkgs.stdenv.isLinux {
          "xdg/autostart/mpv.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Name=MPV
            Exec=${pkgs.mpv}/bin/mpv
            X-GNOME-Autostart-enabled=true
          '';
        };
      };
  };
}
