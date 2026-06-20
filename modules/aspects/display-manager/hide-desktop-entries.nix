{
  den.aspects.display-manager.hide-desktop-entries = {
    nixos =
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
          blueman-manager = "Bluetooth Manager";
          blueman-adapters = "Bluetooth Adapters";
          "nixos-manual" = "NixOS Manual";
          fish = "fish";
          foot = "Foot";
          footclient = "Foot (Client)";
          foot-server = "Foot (Server)";
          vim = "vim";
          gvim = "gvim";
          rofi = "Rofi";
          rofi-theme-selector = "Rofi Theme Selector";

          base = "LibreOffice Base";
          calc = "LibreOffice Calc";
          draw = "LibreOffice Draw";
          impress = "LibreOffice Impress";
          math = "LibreOffice Math";
          startcenter = "LibreOffice Startcenter";
          writer = "LibreOffice Writer";
          xsltfilter = "LibreOffice xsltfilter";

          qt5ct = "QT5 Settings";
          qt6ct = "QT6 Settings";
          kvantummanager = "Kvantum Manager";
        };
      in
      {
        environment.systemPackages = hidden;
      };
  };
}
