{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.hideDesktopEntries ];
  den.aspects.hideDesktopEntries = den.lib.perHost {
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
  };
}
