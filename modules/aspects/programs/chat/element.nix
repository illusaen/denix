{
  den.aspects.programs.chat.element = {
    provides.to-users.persistUser.directories = [
      ".config/Element"
    ];

    os = {pkgs, ...}: {
      nixpkgs.overlays = [
        (_: prev: {
          element-desktop = prev.element-desktop.overrideAttrs (old: {
            postFixup =
              (old.postFixup or "")
              + ''
                sed -i 's|^Exec=\([^ ]*\) .*|Exec=\1 --password-store="gnome-libsecret"|' \
                  $out/share/applications/element-desktop.desktop
              '';
          });
        })
      ];
      environment.systemPackages = with pkgs; [element-desktop];
    };
  };
}
