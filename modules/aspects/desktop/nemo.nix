{ den, lib, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.nemo ];

  den.aspects.xdg.mime = {
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

  den.aspects.nemo = den.lib.perHost {
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
  };
}
