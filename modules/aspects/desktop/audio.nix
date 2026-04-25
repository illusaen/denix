{ den, ... }:
{
  den.aspects.desktop._.audio = den.lib.perHost {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ pavucontrol ];
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
        security.rtkit.enable = lib.mkDefault true;
      };
  };
}
