{
  rootPath,
  lib,
  ...
}: {
  config.den.aspects.programs.wallpaper = {
    settings.wallpaper = lib.mkOption {
      type = lib.types.path;
      default = rootPath + /resources/wallpapers/dark-silk.jpeg;
    };

    wrapper-packages = {host, ...}: {
      wpaperd = {
        imports = [(rootPath + /wrappers/wpaperd.nix)];
        imageDirectory = rootPath + "/resources/wallpapers";
        monitors = {
          main = host.settings."display-manager".monitor.main.connector;
          secondary = host.settings."display-manager".monitor.secondary.connector;
        };
      };
    };

    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.local.wpaperd];
      systemd.packages = [pkgs.local.wpaperd];
      systemd.user.services.wpaperd.wantedBy = ["graphical-session.target"];
    };

    darwin = {host, ...}: {
      system.activationScripts.setDesktopBackground = ''
        echo "Setting desktop background."
        osascript -e 'tell application "System Events" to tell every desktop to set picture to "${host.settings.programs.wallpaper.wallpaper}"'
      '';
    };
  };
}
