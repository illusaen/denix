{
  den,
  lib,
  inputs,
  ...
}:
let
  wallpaper = ../../resources/cube-dark.jpg;
in
{
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.ctx.host.includes = [ den.aspects.stylix ];
  den.aspects.stylix =
    { host, ... }:
    {
      os =
        { pkgs, ... }:
        let
          image = wallpaper;
          polarity =
            if (isNull base16Scheme) then
              lib.pipe image [
                baseNameOf
                (lib.splitString ".")
                lib.init
                lib.last
                (lib.splitString "-")
                lib.last
              ]
            else
              "dark";
          base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
        in
        {
          stylix = {
            enable = true;
            autoEnable = true;
            inherit polarity image base16Scheme;

            icons = {
              enable = true;
              package = pkgs.colloid-icon-theme;
              dark = "Colloid-Dark";
              light = "Colloid-Light";
            };

            cursor = {
              name = "Nordic-cursors";
              size = 28;
              package = pkgs.nordic;
            };

            fonts = {
              serif = host.fonts.sans;
              sansSerif = host.fonts.sans;
              monospace = host.fonts.mono;
              emoji = host.fonts.emoji;

              sizes = host.fonts.sizes;
            };

            targets.gtksourceview.enable = false;
          };
        };

      nixos.imports = [ inputs.stylix.nixosModules.stylix ];

      darwin.imports = [ inputs.stylix.darwinModules.stylix ];
    };
}
