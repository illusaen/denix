DEPTH="${1:-3}"
PERSIST_DIR="@persistMount@"

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
  | jq -s --argjson persisted '@persisted@' --arg mount "$PERSIST_DIR" "$dir_filter"

fd -H -t f -d "$DEPTH" -a . "$PERSIST_DIR" \
  | jq -R . \
  | jq -s --argjson persisted '@persisted@' --arg mount "$PERSIST_DIR" "$file_filter"
