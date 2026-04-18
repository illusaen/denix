{ den, ... }:
{
  den.aspects.element = den.lib.perHost {
    persistUser.directories = [
      ".config/Element"
    ];

    nixos = {
      nixpkgs.overlays = [
        (_: prev: {
          element-desktop = prev.element-desktop.overrideAttrs (old: {
            postFixup = (old.postFixup or "") + ''
              sed -i 's|^Exec=\([^ ]*\) .*|Exec=\1 --password-store="gnome-libsecret"|' \
                $out/share/applications/element-desktop.desktop
            '';
          });
        })
      ];
    };

    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ element-desktop ];
      };
  };
}
