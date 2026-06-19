{ rootPath, lib, ... }:
{
  options.fleet.my.wallpaper = lib.mkOption {
    type = lib.types.path;
    default = rootPath + /resources/gold-dragon.jpeg;
  };

  config.den.aspects.programs.wallpaper = {
    wrapper-packages.wpaperd = {
      imports = [ (rootPath + /wrappers/wpaperd.nix) ];
      imageDirectory = rootPath + "/resources";
    };

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.local.wpaperd ];
        systemd.packages = [ pkgs.local.wpaperd ];
      };

    darwin = { fleet, ... }: {
      system.activationScripts.setDesktopBackground = ''
        echo "Setting desktop background."
        osascript -e 'tell application "System Events" to tell every desktop to set picture to "${fleet.my.wallpaper}"'
      '';
    };
  };
}
