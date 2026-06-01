{ den, ... }:
{
  den.aspects.base.cli.includes = with den.aspects.base.cli; [
    bat
    direnv
    fish
    git
    neovide
    nix-index
    opnix
    shell-utils
    ssh
    starship
  ];
}
