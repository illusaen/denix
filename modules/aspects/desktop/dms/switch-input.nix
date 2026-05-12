{
  den.aspects.wm.switch-input = {
    nixos =
      {
        pkgs,
        ...
      }:
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

    provides.to-users = {
      user.extraGroups = [ "i2c" ];
    };
  };
}
