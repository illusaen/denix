{
  den.aspects.base.cli.neovide = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          neovide
          neovim
        ];
      };
  };
}
