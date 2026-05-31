USER="$(whoami)"
DEPTH="${1:-3}"

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
    | jq -s --argjson persisted '@persisted@' --argjson ignored '@ignored@' "$dir_filter"

    fd -H -t f -d "$DEPTH" -a . "$SCAN_DIR" \
    | jq -R . \
    | jq -s --argjson persisted '@persisted@' --argjson ignored '@ignored@' "$file_filter"
done
