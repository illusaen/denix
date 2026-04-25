{ den, lib, ... }:
{
  den.aspects.desktop._.nemo = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        services.gvfs.enable = true;
        services.udisks2.enable = true;
        services.tumbler.enable = true;

        environment.systemPackages = with pkgs; [
          (nemo-with-extensions.override {
            extensions = [
              nemo-preview # Quick previewer for Nemo
              nemo-seahorse # GNOME encryption keys management
            ];
          })
        ];

        programs.dconf.profiles.user.databases = [
          {
            settings = {
              "org/nemo/preferences" = {
                show-image-thumbnails = "always";
                show-hidden-files = true;
                thumbnail-limit = lib.gvariant.mkUint64 104857600;
              };
            };
          }
        ];
      };

    hj.xdg.mime-apps = {
      default-applications = lib.mkBefore (
        let
          application = "nemo.desktop";
          mimeTypes = [
            "inode/directory"
            "application/x-gnome-saved-search"
          ];
        in
        lib.genAttrs mimeTypes (_: application)
      );
      added-associations =
        let
          application = "nemo-autorun-software.desktop";
          mimeTypes = [
            "x-content/unix-software"
          ];
        in
        lib.genAttrs mimeTypes (_: application);
    };
  };
}
