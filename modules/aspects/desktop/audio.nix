{ den, ... }:
{
  den.aspects.desktop._.audio = den.lib.perHost {
    nixos =
      { pkgs, ... }:
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
      };

    hj =
      { pkgs, lib, ... }:
      {
        xdg.config.files = lib.mkIf pkgs.stdenv.isLinux {
          "autostart/mpv.desktop".text = ''
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
