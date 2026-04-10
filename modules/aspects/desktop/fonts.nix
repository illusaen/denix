{
  den,
  inputs,
  ...
}:
{
  den.schema.host =
    { lib, host, ... }:
    let
      pkgs = inputs.nixpkgs.legacyPackages."${host.system}";

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
      options =
        let
          fontOption = lib.mkOption {
            type = lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                };
                package = lib.mkOption {
                  type = lib.types.package;
                };
              };
            };
          };
        in
        {
          fonts = lib.mkOption {
            type = lib.types.submodule {
              options = {
                sans = fontOption;
                mono = fontOption;
                emoji = fontOption;
                icon = fontOption;
              };
            };
          };
        };
      config.fonts = {
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
      };
    };

  den.aspects.desktop.includes = [ den.aspects.fonts ];
  den.aspects.fonts =
    { host, ... }:
    {
      os =
        { pkgs, lib, ... }:
        {
          fonts.packages = [
            pkgs.font-awesome
            pkgs.material-icons
          ]
          ++ (lib.pipe host.fonts [
            (lib.filterAttrs (_: v: builtins.isAttrs v && builtins.hasAttr "package" v))
            (lib.mapAttrsToList (_: value: value.package))
          ]);
        };
      nixos = {
        fonts.fontconfig.defaultFonts = rec {
          monospace = [ host.fonts.mono.name ];
          serif = sansSerif;
          sansSerif = [ host.fonts.sans.name ];
        };
      };
    };
}
