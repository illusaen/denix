{
  inputs,
  lib,
  ...
}:
let
  base16Scheme = ./cosmic.yaml;
  base16Msg = import (inputs.base16 + "/lib/msg.nix");
  mkFromYaml = import (inputs.base16.inputs.fromYaml + "/fromYaml.nix") { inherit lib; };
  mkBase16Util =
    {
      pkgs ? null,
    }:
    import (inputs.base16 + "/lib/util.nix") {
      inherit lib pkgs;
      msg = base16Msg;
      fromYaml = mkFromYaml;
    };
  colors =
    let
      util = mkBase16Util { };
    in
    import (inputs.base16 + "/lib/colors.nix") {
      inherit lib;
      inherit (util) normalize-colors;
    };
  fromYaml = mkFromYaml;
  util = mkBase16Util { };
  parsedScheme = util.convert-scheme-to-common-format (fromYaml (builtins.readFile base16Scheme));
  inputAttrs = colors.colors parsedScheme;
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
  schemeAttrs = inputAttrs // inputMeta // builderMeta;
in
{
  options.fleet.my = {
    base16 = lib.mkOption {
      type = lib.types.submodule {
        options.colorScheme = lib.mkOption {
          type = lib.types.enum [
            "dark"
            "light"
          ];
        };
      };
    };
    scheme = lib.mkOption {
      type = lib.types.raw;
      readOnly = true;
    };
  };

  config = {
    flake-file.inputs.base16.url = "github:SenchoPens/base16.nix";

    fleet.my = {
      base16.colorScheme = "dark";
      scheme = schemeAttrs // {
        withHashtag = schemeAttrs.withHashtag // inputMeta // builderMeta;
        render =
          {
            pkgs,
            lib,
            ...
          }@args:
          let
            renderUtil = mkBase16Util { inherit pkgs; };
            mkTheme = import (inputs.base16 + "/lib/mk-theme.nix") (
              {
                inherit lib pkgs;
                msg = base16Msg;
                fromYaml = mkFromYaml;
              }
              // renderUtil
            );
          in
          mkTheme.mkTheme (
            (removeAttrs args [
              "lib"
              "pkgs"
            ])
            // {
              scheme = schemeAttrs // {
                withHashtag = schemeAttrs.withHashtag // inputMeta // builderMeta;
              };
            }
          );
      };
    };
  };
}
