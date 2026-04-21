{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.theming ];
  den.aspects.theming = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          adw-gtk3
          adwaita-qt6
          dracula-icon-theme
          nordic
          # (kdePackages.qt6ct.overrideAttrs (oldAttrs: {
          #   patches = (oldAttrs.patches or [ ]) ++ [ ./qt6ct-0.11.patch ];
          #   nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
          #     pkgs.qt6.wrapQtAppsHook
          #     pkgs.kdePackages.qttools
          #     pkgs.kdePackages.qtsvg
          #     pkgs.kdePackages.qtbase
          #     cmake
          #   ];
          # }))
          kdePackages.qt6ct
          kdePackages.qtstyleplugin-kvantum
          libsForQt5.qt5ct
          libsForQt5.qtstyleplugin-kvantum
        ];
      };
  };
}
