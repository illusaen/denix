{ den, ... }:
{
  den.aspects.desktop._.gui = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          qalculate-gtk
          inkscape
          usbimager
        ];

        services.flatpak.enable = true;
      };

    persist.directories = [
      "/var/lib/flatpak"
    ];

    persistUser.directories = [
      ".local/share/flatpak"
      ".var/app/com.bambulab.BambuStudio"
    ];
  };
}
