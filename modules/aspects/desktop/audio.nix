{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.audio ];

  den.aspects.audio = {
    includes = with den.aspects.audio._; [ pipewire ];

    _.pipewire = den.lib.perHost {
      nixos =
        { lib, pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [ pavucontrol ];
          services = {
            pulseaudio.enable = lib.mkDefault false;
            playerctld.enable = true;

            pipewire = {
              enable = lib.mkDefault true;
              alsa.enable = lib.mkDefault true;
              alsa.support32Bit = lib.mkDefault true;
              pulse.enable = lib.mkDefault true;
              wireplumber.enable = lib.mkDefault true;
            };
          };
          security.rtkit.enable = lib.mkDefault true;
        };
    };
  };
}
