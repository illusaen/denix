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
            pulseaudio.enable = false;
            playerctld.enable = true;

            pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;
            };

            pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
              "monitor.bluez.properties" = {
                "bluez5.enable-sbc-xq" = true;
                "bluez5.enable-msbc" = true;
                "bluez5.enable-hw-volume" = true;
                "bluez5.roles" = [
                  "hsp_hs"
                  "hsp_ag"
                  "hfp_hf"
                  "hfp_ag"
                ];
              };
            };
          };
          security.rtkit.enable = lib.mkDefault true;
        };
    };
  };
}
