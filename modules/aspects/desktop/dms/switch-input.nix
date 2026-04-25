{ den, ... }:
{
  den.aspects.desktop._.switch-input = {
    includes = with den.aspects.desktop._.switch-input._; [
      enable
      group
    ];

    _.enable = den.lib.perHost {
      nixos =
        { pkgs, ... }:
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
        };
    };

    _.group = den.lib.perUser (
      { user, ... }:
      {
        nixos.users.users.${user.name}.extraGroups = [ "i2c" ];
      }
    );
  };
}
