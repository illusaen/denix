{ den, lib, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.nemo ];

  # den.aspects.xdg.mime = {
  #   defaultApplications = lib.mkBefore (
  #     let
  #       application = "nemo.desktop";
  #       mimeTypes = [
  #         "inode/directory"
  #         "application/x-gnome-saved-search"
  #       ];
  #     in
  #     lib.genAttrs mimeTypes (_: application)
  #   );
  #   associations.added =
  #     let
  #       application = "nemo-autorun-software.desktop";
  #       mimeTypes = [
  #         "x-content/unix-software"
  #       ];
  #     in
  #     lib.genAttrs mimeTypes (_: application);
  # };

  den.aspects.nemo = {
    mime = {
      defaultApplications = lib.mkBefore (
        let
          application = "nemo.desktop";
          mimeTypes = [
            "inode/directory"
            "application/x-gnome-saved-search"
          ];
        in
        lib.genAttrs mimeTypes (_: application)
      );
      associations.added =
        let
          application = "nemo-autorun-software.desktop";
          mimeTypes = [
            "x-content/unix-software"
          ];
        in
        lib.genAttrs mimeTypes (_: application);
    };

    nixos =
      { pkgs, ... }:
      {
        services.gvfs.enable = true;
        services.udisks2.enable = true;
        services.tumbler.enable = true;

        environment.systemPackages = with pkgs; [
          (nemo-with-extensions.override {
            # Disable the default extensions so we can explicity declare them ourself
            useDefaultExtensions = false;
            extensions = [
              nemo-python # Dependency of `nemo-emblems`
              nemo-emblems # Enables folder/file emblem change tab
              nemo-preview # Quick previewer for Nemo
              nemo-fileroller # Archive management within Nemo
              nemo-seahorse # GNOME encryption keys management
            ];
          })
        ];
      };

    md =
      { pkgs, ... }:
      {
        dconf.settings = {
          "/org/nemo/preferences" = {
            show-hidden-files = lib.mkDefault true;
            date-format = lib.mkDefault "iso";
            quick-renames-with-pause-in-between = lib.mkDefault true;
            thumbnail-limit = lib.mkDefault 10485760;
          };

          "/org/nemo/preferences/menu-config" = {
            selection-menu-make-link = lib.mkDefault true;
          };

          "/org/nemo/plugins" = {
            disabled-actions = lib.mkDefault [
              "set-as-background.nemo_action"
              "change-background.nemo_action"
              "add-desklets.nemo_action"
              "90_new-launcher.nemo_action"
              "set-resolution.nemo_action"
            ];
          };

          "/org/gtk/settings/file-chooser" = {
            show-hidden = lib.mkDefault true;
          };

          "/org/cinnamon/desktop/applications/terminal" = {
            # Default terminal is set to kitty (change this if using another terminal)
            exec = lib.mkDefault "${lib.getExe pkgs.kitty}";
          };
        };
      };
  };
}
