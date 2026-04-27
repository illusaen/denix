{ den, ... }:
{
  den.aspects.theming._.dconf = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          (pkgs.writeShellApplication {
            name = "dconf2nix";
            runtimeInputs = with pkgs; [
              python3
            ];
            text = ''
              python3 ${./dconf-to-nix.py} "$@"
            '';
          })
        ];
      };
  };
}
