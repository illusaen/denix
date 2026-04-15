{
  den,
  ...
}:
{
  den.schema.host =
    { lib, ... }:
    {
      options.mime =
        with lib;
        let
          strListOrSingleton = with types; coercedTo (either (listOf str) str) lib.toList (listOf str);
        in
        {
          associations.added = mkOption {
            type = types.attrsOf strListOrSingleton;
            default = { };
            example = lib.literalExpression ''
              {
                "mimetype1" = [ "foo1.desktop" "foo2.desktop" "foo3.desktop" ];
                "mimetype2" = "foo4.desktop";
              }
            '';
            description = ''
              Defines additional associations of applications with
              mimetypes, as if the .desktop file was listing this mimetype
              in the first place.
            '';
          };

          associations.removed = mkOption {
            type = types.attrsOf strListOrSingleton;
            default = { };
            example = {
              "mimetype1" = "foo5.desktop";
            };
            description = ''
              Removes associations of applications with mimetypes, as if the
              .desktop file was *not* listing this
              mimetype in the first place.
            '';
          };

          defaultApplications = mkOption {
            type = types.attrsOf strListOrSingleton;
            default = { };
            example = lib.literalExpression ''
              {
                "mimetype1" = [ "default1.desktop" "default2.desktop" ];
              }
            '';
            description = ''
              The default application to be used for a given mimetype. This
              is, for instance, the one that will be started when
              double-clicking on a file in a file manager. If the
              application is no longer installed, the next application in
              the list is attempted, and so on.
            '';
          };

          defaultApplicationPackages = mkOption {
            type = types.listOf types.package;
            default = [ ];
            example = [
              pkgs.eog
              pkgs.evince
            ];
            description = ''
              Packages whose `.desktop` files will be used to establish default
              mimetype associations.

              These associations are appended to the associations in
              [](#opt-xdg.mimeApps.defaultApplications). If multiple packages
              associate with the same mime type, then the priority among them is
              determined by their order in the list.
            '';
          };
        };
    };

  den.aspects.desktop.includes = [ den.aspects.xdg ];

  den.aspects.xdg =
    { host, ... }:
    {
      md =
        {
          pkgs,
          lib,
          ...
        }:
        {
          file.xdg_config."user-dirs.dirs".text = ''
            XDG_DOWNLOAD_DIR="{{home}}/Downloads"
            XDG_PICTURES_DIR="{{home}}/Pictures"
          '';
          file.xdg_config."user-dirs.conf".text = "enabled=False";

          file.xdg_config."mimeapps.list".source =
            let
              joinValues = lib.mapAttrs (_: lib.concatStringsSep ";");

              baseFile = (pkgs.formats.ini { }).generate "mimeapps.list" {
                "Added Associations" = joinValues host.mime.associations.added;
                "Removed Associations" = joinValues host.mime.associations.removed;
                "Default Applications" = joinValues host.mime.defaultApplications;
              };

              # With default application packages merged into the generated base file.
              mergedFile = pkgs.runCommand "mimeapps.list" { ps = host.mime.defaultApplicationPackages; } ''
                export PATH=$PATH:${pkgs.crudini}/bin

                function mergeEntry() {
                  local mime="$1"
                  local name="$2"
                  local existing

                  existing="$(crudini --get $out 'Default Applications' "$mime" 2>/dev/null || true)"
                  local value="$existing''${existing:+;}''$name"
                  crudini --ini-options=nospace --inplace --set $out 'Default Applications' "$mime" "$value"
                }

                install -m644 ${baseFile} $out

                for p in $ps ; do
                  for path in "$p"/share/applications/*.desktop ; do
                    name="''${path##*/}"
                    mimes=$(crudini --get "$path" 'Desktop Entry' MimeType 2>/dev/null || true)
                    for mime in ''${mimes//;/ }; do
                      mergeEntry "$mime" "$name"
                    done
                  done
                done
              '';
            in
            if host.mime.defaultApplicationPackages == [ ] then baseFile else mergedFile;
        };

      nixos =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [ xdg-user-dirs ];
        };
    };
}
