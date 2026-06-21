{den, ...}: {
  den.aspects.base.cli.includes = with den.aspects.base.cli; [
    fish
    nvf
    nix-index
    opnix
    shell-utils
    starship
  ];
}
