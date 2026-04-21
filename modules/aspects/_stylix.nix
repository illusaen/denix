{
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

  # den.ctx.host.includes = [ den.aspects.stylix ];
  den.aspects.stylix =
    { host, ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          stylix = {
            cursor = {
              name = "Nordic-cursors";
              size = 28;
              package = pkgs.nordic;
            };
            icons = {
              enable = true;
              package = pkgs.colloid-icon-theme;
              dark = "Colloid-Dark";
              light = "Colloid-Light";
            };

            targets.gtksourceview.enable = false;
          };

          imports = [ inputs.stylix.nixosModules.stylix ];
        };

      os =
        { pkgs, ... }:
        let
          image = wallpaper;
          polarity =
            if (base16Scheme == null) then
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

            fonts = {
              serif = host.fonts.sans;
              sansSerif = host.fonts.sans;
              monospace = host.fonts.mono;
              inherit (host.fonts) emoji;

              inherit (host.fonts) sizes;
            };
          };
        };

      darwin.imports = [ inputs.stylix.darwinModules.stylix ];
    };
}
