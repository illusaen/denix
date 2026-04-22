{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.switch-input ];
  den.aspects.switch-input = den.lib.perHost {
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

  den.aspects.wendy =
    { user, ... }:
    {
      nixos.users.users.${user.name}.extraGroups = [ "i2c" ];
    };
}
