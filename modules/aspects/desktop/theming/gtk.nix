{
  den,
  lib,
  inputs,
  ...
}:
{
  den.aspects.desktop.includes = [ den.aspects.gtk ];
  den.aspects.gtk = {
    includes = lib.attrValues den.aspects.gtk._;

    _.enable.nixos.programs.dconf.enable = true;
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
            colors = osConfig.lib.base16.mkSchemeAttrs "${inputs.tt-schemes}/base24/chalk.yaml";

            gtkSettings = {
              theme = {
                package = pkgs.adw-gtk3;
                name = "adw-gtk3";
              };
            };

            gtkBaseCss = colors {
              template = ./_templates/gtk.css.mustache;
              extension = ".css";
            };
            gtkExtraCss = "";
            gtkFinalCss = pkgs.runCommandLocal "gtk.css" { } ''
              cat ${gtkBaseCss} >>$out
              echo ${lib.escapeShellArg gtkExtraCss} >>$out
            '';
            gtkSettingsFile = version: { "gtk-${version}/gtk.css".source = gtkFinalCss; };
          in
          {
            xdg.config.files = lib.mkMerge (
              lib.flatten [
                (map gtkSettingsFile [
                  "3.0"
                  "4.0"
                ])
              ]
            );

            xdg.data.files."flatpak/overrides/global".text = ''
              [Context]
              filesystems=${osConfig.users.users.${user.name}.home}/.themes/${gtkSettings.theme.name}:ro

              [Environment]
              GTK_THEME=${gtkSettings.theme.name}
            '';

            files.".themes/${gtkSettings.theme.name}".source = pkgs.stdenvNoCC.mkDerivation {
              name = "flattenedGtkTheme";
              src = "${gtkSettings.theme.package}/share/themes/${gtkSettings.theme.name}";

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
