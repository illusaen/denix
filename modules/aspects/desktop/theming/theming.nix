{
  den,
  inputs,
  ...
}:
{
  flake-file.inputs = {
    base16.url = "github:SenchoPens/base16.nix";
    tt-schemes = {
      url = "github:tinted-theming/schemes/spec-0.11";
      flake = false;
    };
  };

  den.aspects.desktop.includes = [ den.aspects.theming ];
  den.aspects.theming = {
    nixos =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        options.theming = lib.mkOption {
          type = lib.types.submodule {
            options = {
              colors = lib.mkOption {
                type = lib.types.anything;
              };
              base16Scheme = lib.mkOption {
                type = lib.types.path;
              };
              schemeName = lib.mkOption {
                type = lib.types.str;
              };
            };
          };
        };

        imports = [ inputs.base16.nixosModule ];

        config = {
          theming = {
            colors = config.lib.base16.mkSchemeAttrs config.theming.base16Scheme;
            base16Scheme = "${inputs.tt-schemes}/base24/${config.theming.schemeName}.yaml";
            schemeName = "chalk";
          };

          environment.systemPackages = with pkgs; [
            adw-gtk3
            adwaita-qt6
            dracula-icon-theme
            nordic
          ];
        };
      };
  };
}
