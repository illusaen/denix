{ den, lib, ... }:
{
  den.aspects.find-ephemeral = den.lib.perHost {
    nixos =
      { config, pkgs, ... }:
      lib.mkIf (config ? preservation.preserveAt) (
        let
          inherit (den.aspects.preservation) persistMount;
          cfg = config.preservation.preserveAt.${persistMount};

          combined =
            attr:
            cfg.${attr}
            ++ lib.pipe cfg.users [
              builtins.attrNames
              (map (u: cfg.users.${u}.${attr}))
              lib.flatten
            ];

          filterPaths =
            configAttr: pathSegment:
            lib.pipe configAttr [
              combined
              (builtins.catAttrs pathSegment)
            ];

          persisted = builtins.toJSON {
            directories = filterPaths "directories" "directory"; # preservation.preserveAt."/persisted".directories => { directory = "/etc/folder"; ...}
            files = filterPaths "files" "file";
          };

          ignored = builtins.toJSON [
            "/etc/systemd"
            "/etc/terminfo"
            "/etc/static"
            "/etc/zoneinfo"
            "/etc/kbd"
            "/etc/zfs"
            "/etc/egl"
            "/etc/egl"
            "/etc/pipewire"
            "/etc/udev"
            "/etc/fonts"
            "/etc/speech-dispatcher"
            "/etc/pam.d"
            "/etc/pam"
            "/etc/fish/generated_completions"
            "/home/*/.steam"
          ];

          find-ephemeral = pkgs.writeShellApplication {
            name = "ff";
            runtimeInputs = with pkgs; [
              fd
              jq
            ];
            text = ''
              #!${pkgs.runtimeShell}
              USER=''$(whoami)
              DEPTH="''${1:-3}"

              SCAN_DIRS=("/home/$USER" "/etc")

              # shellcheck disable=SC2016
              dir_filter='
                def under($dirs):
                  . as $path
                  | any($dirs[]; . as $dir | $path == $dir or ($path | startswith($dir + "/")));

                def segment_glob_prefix($pattern):
                  . as $path
                  | ($path | split("/")) as $path_parts
                  | ($pattern | split("/")) as $pattern_parts
                  | ($path_parts | length) >= ($pattern_parts | length)
                    and all(range(0; ($pattern_parts | length)); $pattern_parts[.] == "*" or $path_parts[.] == $pattern_parts[.]);

                def ignored($dirs):
                  . as $path
                  | any($dirs[]; . as $pattern | $path | segment_glob_prefix($pattern));

                map(select((under($persisted.directories) or ignored($ignored)) | not)) | .[]
              '

              # shellcheck disable=SC2016
              file_filter='
                def under($dirs):
                  . as $path
                  | any($dirs[]; . as $dir | $path == $dir or ($path | startswith($dir + "/")));

                def segment_glob_prefix($pattern):
                  . as $path
                  | ($path | split("/")) as $path_parts
                  | ($pattern | split("/")) as $pattern_parts
                  | ($path_parts | length) >= ($pattern_parts | length)
                    and all(range(0; ($pattern_parts | length)); $pattern_parts[.] == "*" or $path_parts[.] == $pattern_parts[.]);

                def ignored($dirs):
                  . as $path
                  | any($dirs[]; . as $pattern | $path | segment_glob_prefix($pattern));

                def persisted_file:
                  . as $path
                  | any($persisted.files[]; . as $file | $path == $file);

                map(select((persisted_file or under($persisted.directories) or ignored($ignored)) | not)) | .[]
              '

              # Find all files and directories
              for SCAN_DIR in "''${SCAN_DIRS[@]}"; do
                if [[ ! -d $SCAN_DIR ]]; then
                  continue
                fi

                fd -H -t d -d "$DEPTH" -a . "$SCAN_DIR" \
                  | jq -R . \
                  | jq -s --argjson persisted '${persisted}' --argjson ignored '${ignored}' "$dir_filter"

                fd -H -t f -d "$DEPTH" -a . "$SCAN_DIR" \
                  | jq -R . \
                  | jq -s --argjson persisted '${persisted}' --argjson ignored '${ignored}' "$file_filter"
              done
            '';
          };
        in
        {
          environment.systemPackages = [
            find-ephemeral
          ];
          environment.etc."persisted-paths.json".text = persisted;
        }
      );
  };
}
