{
  den.aspects.base.bluetooth = {
    nixos = {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Experimental = true;
          };
        };
      };

      services.blueman.enable = true;
    };

    persist.directories = [
      "/var/lib/bluetooth"
    ];
  };
}
