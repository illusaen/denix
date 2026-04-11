{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.hideDesktopEntries ];
  den.aspects.hideDesktopEntries.nixos =
    { pkgs, lib, ... }:
    let
      mkHiddenDesktopEntries = drvName: pkgs: entries: [
        (pkgs.stdenvNoCC.mkDerivation {
          name = "${drvName}-hidden-desktop-entries";
          meta.priority = 1;
          phases = [
            "buildPhase"
            "installPhase"
          ];
          buildPhase = lib.pipe entries [
            (lib.mapAttrsToList (
              name: value:
              "echo -e \"[Desktop Entry]\nName=${value}\nType=Application\nNoDisplay=true\n\" > ${name}.desktop"
            ))
            (lib.concatStringsSep "\n")
          ];
          installPhase = ''
            mkdir -p $out/share/applications
            mv *.desktop $out/share/applications
          '';
        })
      ];

      hidden = mkHiddenDesktopEntries "other" pkgs {
        kvantummanager = "Kvantum Manager";
        blueman-manager = "Bluetooth Manager";
        qt5ct = "Qt5 Configuration Tool";
        qt6ct = "Qt6 Configuration Tool";
        "nixos-manual" = "NixOS Manual";
        fish = "fish";
        vim = "vim";
        gvim = "gvim";
        kitty = "kitty";
        kitty-open = "kitty-open";
        "org.pulseaudio.pavucontrol" = "pavucontrol";
      };
    in
    {
      environment.systemPackages = hidden;
    };
}
