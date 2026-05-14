{ den, ... }:
{
  den.aspects.theming.includes = with den.aspects.theming; [ dconf ];

  den.aspects.theming.dconf = {
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
