{ den, lib, ... }:
{
  den.aspects.find-ephemeral = den.lib.perHost {
    nixos =
      { config, pkgs, ... }:
      lib.mkIf (config.environment ? persistence) (
        let
          inherit (den.aspects.preservation) persistMount;
          inherit (config.preservation.preserveAt.${persistMount})
            directories
            files
            users
            ;

          appendHome =
            user: attr: path:
            "/home/${user}/${path."${attr}"}";
          appendedUserDirs =
            user:
            (map (appendHome user "dirPath") users.${user}.directories)
            ++ (map (appendHome user "filePath") users.${user}.files);
          persisted = builtins.toJSON (
            directories ++ files ++ lib.flatten (map appendedUserDirs (builtins.attrNames users))
          );

          find-ephemeral = pkgs.writeShellApplication {
            name = "ff";
            runtimeInputs = with pkgs; [ jq ];
            text = ''
              #!${pkgs.runtimeShell}
              USER=''$(whoami)

              # Function to check if a path is persisted
              is_persisted() {
                local path=$1
                # Check if it's a persisted file
                if echo "${persisted}" | grep -q "^''${path}$"; then
                  return 0
                fi
                # Check if under a persisted directory
                for dir in $dirs; do
                  if [[ $path == $dir/* ]]; then
                    return 0
                  fi
                done
                return 1
              }

              SCAN_DIRS=("/home/$USER" "/etc")
              # Find all files and directories
              for SCAN_DIR in "''${SCAN_DIRS[@]}"; do
                if [[ ! -d $SCAN_DIR ]]; then
                  continue
                fi

                fd -H -E .git -t f -t d -a . "$SCAN_DIR" -x bash -c '[[ ! is_persisted "$1" ]] && echo "$1"' _ {}
              done
            '';
          };
        in
        {
          environment.systemPackages = [ find-ephemeral ];
        }
      );
  };
}
