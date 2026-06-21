{
  den.aspects.base.audio = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [pavucontrol];
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
  };
}
