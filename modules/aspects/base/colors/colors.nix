{
  den,
  inputs,
  ...
}:
let
  base16Scheme = ./cosmic.yaml;
  base16Msg = import (inputs.base16 + "/lib/msg.nix");
  mkFromYaml = lib: import (inputs.base16.inputs.fromYaml + "/fromYaml.nix") { inherit lib; };
  mkBase16Util =
    {
      lib,
      pkgs ? null,
    }:
    import (inputs.base16 + "/lib/util.nix") {
      inherit lib pkgs;
      msg = base16Msg;
      fromYaml = mkFromYaml lib;
    };
  mkBase16Colors =
    { lib }:
    let
      util = mkBase16Util { inherit lib; };
    in
    import (inputs.base16 + "/lib/colors.nix") {
      inherit lib;
      inherit (util) normalize-colors;
    };
  renderBase16Theme =
    {
      lib,
      pkgs,
      scheme,
      ...
    }@args:
    let
      util = mkBase16Util { inherit lib pkgs; };
      mkTheme = import (inputs.base16 + "/lib/mk-theme.nix") (
        {
          inherit lib pkgs;
          msg = base16Msg;
          fromYaml = mkFromYaml lib;
        }
        // util
      );
    in
    mkTheme.mkTheme (
      (removeAttrs args [
        "lib"
        "pkgs"
      ])
      // {
        inherit scheme;
      }
    );
in
{
  flake-file.inputs = {
    base16.url = "github:SenchoPens/base16.nix";
  };

  den.aspects.base.includes = with den.aspects.base; [ colors ];

  den.aspects.base.colors = {
    os = {
      imports = [ inputs.base16.nixosModule ];
      scheme = base16Scheme;
    };

    fleet =
      {
        lib,
        ...
      }:
      let
        inherit (lib) mkOption types;
        fromYaml = mkFromYaml lib;
        util = mkBase16Util { inherit lib; };
        colors = mkBase16Colors { inherit lib; };
        parsedScheme = util.convert-scheme-to-common-format (fromYaml (builtins.readFile base16Scheme));
        inputAttrs = colors.mkBase24 parsedScheme;
        inputMeta = rec {
          scheme = "${inputAttrs.scheme or "untitled"}";
          author = "${inputAttrs.author or "untitled"}";
          description = "${inputAttrs.description or scheme}";
          variant = "${inputAttrs.variant or "unspecified"}";
          system = "${inputAttrs.system or "base16"}";
          slug = lib.toLower (lib.strings.sanitizeDerivationName (inputAttrs.slug or scheme));
        };
        builderMeta = {
          scheme-name = inputMeta.scheme;
          scheme-author = inputMeta.author;
          scheme-description = inputMeta.description;
          scheme-slug = inputMeta.slug;
          scheme-slug-underscored = builtins.replaceStrings [ "-" ] [ "_" ] inputMeta.slug;
          scheme-system = inputMeta.system;
          scheme-variant = inputMeta.variant;
        };
        schemeAttrs = colors.colors inputAttrs // inputMeta // builderMeta;

        mkThemingOptionType = types.submodule {
          options = {
            colorScheme = mkOption {
              type = types.enum [
                "dark"
                "light"
              ];
            };
          };
        };
      in
      {
        options.my.base16 = mkOption {
          type = mkThemingOptionType;
        };
        options.my.scheme = mkOption {
          type = types.raw;
          readOnly = true;
        };
        config.my.base16.colorScheme = "dark";
        config.my.scheme = schemeAttrs // {
          withHashtag = schemeAttrs.withHashtag // inputMeta // builderMeta;
          render =
            {
              pkgs,
              lib,
              ...
            }@args:
            renderBase16Theme (
              {
                inherit pkgs lib;
                scheme = schemeAttrs // {
                  withHashtag = schemeAttrs.withHashtag // inputMeta // builderMeta;
                };
              }
              // (removeAttrs args [
                "pkgs"
                "lib"
              ])
            );
        };
      };
  };
}
