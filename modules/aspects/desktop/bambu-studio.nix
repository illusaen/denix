{ den, ... }:
{
  den.aspects.desktop.includes = with den.aspects.desktop; [ bambu-studio ];

  den.aspects.desktop.bambu-studio = {
    nixos = {
      # Forced to use flatpak until login issue fixed
      services.flatpak.enable = true;
    };

    darwin.homebrew.casks = [ "bambu-studio" ];

    persist.directories = [
      "/var/lib/flatpak"
    ];

    provides.to-users.persistUser.directories = [
      ".local/share/flatpak"
      ".var/app/com.bambulab.BambuStudio"
    ];
  };
}
