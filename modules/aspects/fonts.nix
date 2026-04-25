{
  den,
  ...
}:
{
  den.aspects.fonts = den.lib.perHost {
    os =
      {
        pkgs,
        lib,
        config,
        helpers,
        ...
      }:
      let
        inherit (lib)
          mkOption
          types
          ;
        inherit (helpers) mapListToAttrsWith mkSubmoduleOption mkThemeType;
        fontOption = mkOption {
          type = mkThemeType { };
        };
        sizeOption = mkOption {
          type = types.int;
        };

        feather = pkgs.stdenvNoCC.mkDerivation {
          name = "feather";
          src = pkgs.fetchFromGitHub {
            owner = "AT-UI";
            repo = "feather-font";
            rev = "2ac71612ee85b3d1e9e1248cec0a777234315253";
            sha256 = "sha256-W4CHvOEOYkhBtwfphuDIosQSOgEKcs+It9WPb2Au0jo=";
          };
          phases = [
            "installPhase"
          ];
          installPhase = ''
            mkdir -p $out/share/fonts/truetype
            cp -r $src/src/fonts/*.ttf $out/share/fonts/truetype/
          '';
        };

        sf-pro = pkgs.stdenvNoCC.mkDerivation {
          name = "sf-pro";
          src = pkgs.fetchurl {
            url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
            hash = "sha256-W0sZkipBtrduInk0oocbFAXX1qy0Z+yk2xUyFfDWx4s=";
          };
          buildInputs = with pkgs; [
            undmg
            p7zip
          ];
          phases = [
            "unpackPhase"
            "installPhase"
          ];
          unpackPhase = ''
            undmg $src
            7z x "SF Pro Fonts.pkg"
            7z x "Payload~"
          '';
          installPhase = ''
            mkdir -p $out/share/fonts/{opentype,truetype}
            find -name \*.otf -exec mv {} $out/share/fonts/opentype/ \;
            find -name \*.ttf -exec mv {} $out/share/fonts/truetype/ \;
          '';
        };

        sf-mono = pkgs.stdenvNoCC.mkDerivation {
          name = "sf-mono";
          src = pkgs.fetchFromGitHub {
            owner = "shaunsingh";
            repo = "SFMono-Nerd-Font-Ligaturized";
            rev = "dc5a3e6";
            hash = "sha256-AYjKrVLISsJWXN6Cj74wXmbJtREkFDYOCRw1t2nVH2w=";
          };
          phases = [
            "installPhase"
          ];
          installPhase = ''
            mkdir -p $out/share/fonts/opentype
            cp -r $src/*.otf $out/share/fonts/opentype/
          '';
        };
      in
      {
        options.myLib.fonts = mkSubmoduleOption (
          mapListToAttrsWith [ "sans" "mono" "emoji" "icon" ] fontOption
          // {
            sizes = mkSubmoduleOption (mapListToAttrsWith [ "terminal" "applications" "desktop" ] sizeOption);
          }
        );

        config = {
          fonts.packages = [
            pkgs.font-awesome
            pkgs.material-icons
          ]
          ++ (lib.pipe config.myLib.fonts [
            (lib.filterAttrs (_: v: builtins.isAttrs v && builtins.hasAttr "package" v))
            (lib.mapAttrsToList (_: value: value.package))
          ]);

          myLib.fonts = {
            sans = {
              name = "SF Pro Display";
              package = sf-pro;
            };
            mono = {
              name = "Liga SFMono Nerd Font";
              package = sf-mono;
            };
            emoji = {
              name = "Noto Color Emoji";
              package = pkgs.noto-fonts-color-emoji;
            };
            icon = {
              name = "icomoon";
              package = feather;
            };
            sizes = {
              applications = 12;
              desktop = 12;
              terminal = 12;
            };
          };
        };
      };
    nixos =
      { config, ... }:
      {
        fonts.fontconfig.defaultFonts = rec {
          monospace = [ config.myLib.fonts.mono.name ];
          serif = sansSerif;
          sansSerif = [ config.myLib.fonts.sans.name ];
        };

      };
  };
}
