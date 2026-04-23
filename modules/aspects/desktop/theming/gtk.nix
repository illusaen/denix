{
  den,
  lib,
  ...
}:
{
  den.aspects.desktop.includes = [ den.aspects.gtk ];
  den.aspects.gtk = {
    includes = lib.attrValues den.aspects.gtk._;

    _.enable = den.lib.perHost { nixos.programs.dconf.enable = true; };

    _.configure = den.lib.perUser (
      { user, ... }:
      {
        hjem =
          {
            pkgs,
            lib,
            osConfig,
            ...
          }:
          let
            gtkBaseCss = osConfig.myLib.theming.colors {
              template = ./_templates/gtk.css.mustache;
              extension = ".css";
            };
            gtkExtraCss = "";
            gtkFinalCss = pkgs.runCommandLocal "gtk.css" { } ''
              cat ${gtkBaseCss} >>$out
              echo ${lib.escapeShellArg gtkExtraCss} >>$out
            '';
            gtkSettingsFile = version: { "gtk-${version}/gtk.css".source = gtkFinalCss; };

            inherit (lib)
              mkMerge
              flatten
              ;

            gtk = {
              theme = {
                package = pkgs.adw-gtk3;
                name = "adw-gtk3";
              };
            };
          in
          {

            xdg.config.files = mkMerge (flatten [
              (map gtkSettingsFile [
                "3.0"
                "4.0"
              ])
            ]);

            xdg.data.files."flatpak/overrides/global".text = ''
              [Context]
              filesystems=${osConfig.users.users.${user.name}.home}/.themes/${gtk.theme.name}:ro

              [Environment]
              GTK_THEME=${gtk.theme.name}
            '';

            files.".themes/${gtk.theme.name}".source = pkgs.stdenvNoCC.mkDerivation {
              name = "flattenedGtkTheme";
              src = "${gtk.theme.package}/share/themes/${gtk.theme.name}";

              installPhase = ''
                cp --recursive . $out
                cat ${gtkFinalCss} | tee --append $out/gtk-{3,4}.0/gtk.css
              '';
            };
          };
      }
    );
  };
}
