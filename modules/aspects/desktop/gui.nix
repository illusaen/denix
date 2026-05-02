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
          bambu-studio
        ];

        services.flatpak.enable = true;

        nixpkgs.overlays = [
          (_: prev: {
            bambu-studio = prev.bambu-studio.overrideAttrs (_old: rec {
              version = "2.06.00.51";
              src = pkgs.fetchFromGitHub {
                owner = "bambulab";
                repo = "BambuStudio";
                tag = "v${version}";
                hash = "sha256-jLaSUs6OmoD0yw1hOcJarYKfr1rbhB2TwRiBBU0utEI=";
              };
            });
          })
        ];
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
