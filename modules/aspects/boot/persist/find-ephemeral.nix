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
            # preservation.preserveAt."/persisted".directories => { directory = "/etc/folder"; ...}
            directories = filterPaths "directories" "directory";
            files = filterPaths "files" "file";
          };

          ignored = builtins.readFile ./ignored.json;

          find-orphaned = pkgs.writeShellApplication {
            name = "fo";
            runtimeInputs = with pkgs; [
              fd
              jq
            ];
            text = ''
              #!${pkgs.runtimeShell}
              DEPTH="''${1:-3}"
              PERSIST_DIR="${persistMount}"

              if [[ ! -d $PERSIST_DIR ]]; then
                exit 0
              fi

              # shellcheck disable=SC2016
              dir_filter='
                def clean:
                  rtrimstr("/");

                def persisted_path:
                  ($mount + .) | clean;

                def under($dirs):
                  (. | clean) as $path
                  | any($dirs[]; (. | persisted_path) as $dir | $path == $dir or ($path | startswith($dir + "/")));

                def ancestor_of($paths):
                  (. | clean) as $path
                  | any($paths[]; (. | persisted_path) as $persisted_path | $persisted_path | startswith($path + "/"));

                def parent_dirs:
                  persisted_path
                  | split("/") as $parts
                  | [range(2; $parts | length) as $i | $parts[0:$i] | join("/")];

                def intermediate:
                  (. | clean) as $path
                  | any(($persisted.directories + $persisted.files)[]; parent_dirs[] == $path);

                map(select(
                  (
                    under($persisted.directories)
                    or intermediate
                    or ancestor_of($persisted.directories)
                    or ancestor_of($persisted.files)
                  ) | not
                )) | .[]
              '

              # shellcheck disable=SC2016
              file_filter='
                def persisted_path:
                  $mount + .;

                def under($dirs):
                  . as $path
                  | any($dirs[]; (. | persisted_path) as $dir | $path == $dir or ($path | startswith($dir + "/")));

                def persisted_file:
                  . as $path
                  | any($persisted.files[]; (. | persisted_path) as $file | $path == $file);

                map(select((persisted_file or under($persisted.directories)) | not)) | .[]
              '

              fd -H -t d -d "$DEPTH" -a . "$PERSIST_DIR" \
                | jq -R . \
                | jq -s --argjson persisted '${persisted}' --arg mount "$PERSIST_DIR" "$dir_filter"

              fd -H -t f -d "$DEPTH" -a . "$PERSIST_DIR" \
                | jq -R . \
                | jq -s --argjson persisted '${persisted}' --arg mount "$PERSIST_DIR" "$file_filter"
            '';
          };

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
                def clean:
                  rtrimstr("/");

                def under($dirs):
                  (. | clean) as $path
                  | any($dirs[]; (. | clean) as $dir | $path == $dir or ($path | startswith($dir + "/")));

                def segment_glob_prefix($pattern):
                  (. | clean) as $path
                  | ($path | split("/")) as $path_parts
                  | ($pattern | clean | split("/")) as $pattern_parts
                  | ($path_parts | length) >= ($pattern_parts | length)
                    and all(range(0; ($pattern_parts | length)); $pattern_parts[.] == "*" or $path_parts[.] == $pattern_parts[.]);

                def ignored($dirs):
                  . as $path
                  | any($dirs[]; . as $pattern | $path | segment_glob_prefix($pattern));

                def parent_dirs:
                  clean
                  | split("/") as $parts
                  | [range(2; $parts | length) as $i | $parts[0:$i] | join("/")];

                def intermediate:
                  (. | clean) as $path
                  | any(($persisted.directories + $persisted.files)[]; parent_dirs[] == $path);

                map(select((under($persisted.directories) or intermediate or ignored($ignored)) | not)) | .[]
              '

              # shellcheck disable=SC2016
              file_filter='
                def clean:
                  rtrimstr("/");

                def under($dirs):
                  (. | clean) as $path
                  | any($dirs[]; (. | clean) as $dir | $path == $dir or ($path | startswith($dir + "/")));

                def segment_glob_prefix($pattern):
                  (. | clean) as $path
                  | ($path | split("/")) as $path_parts
                  | ($pattern | clean | split("/")) as $pattern_parts
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
            find-orphaned
          ];
          environment.etc."persisted-paths.json".text = persisted;
        }
      );
  };
}
