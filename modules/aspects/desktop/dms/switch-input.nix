{
  den.aspects.desktop._.switch-input =
    { host }:
    {
      nixos =
        { pkgs, lib, ... }:
        let
          switcher = pkgs.writeShellApplication {
            name = "switcher";
            runtimeInputs = with pkgs; [
              ddcutil
              i2c-tools
              python3
            ];
            text = ''
              python3 ${./switch-input.py} "$@"
            '';
          };
        in
        {
          environment.systemPackages = [ switcher ];
          hardware.i2c.enable = true;
          users.users = builtins.listToAttrs (
            map (username: lib.nameValuePair username { extraGroups = [ "i2c" ]; }) (lib.attrNames host.users)
          );
        };
    };
}
