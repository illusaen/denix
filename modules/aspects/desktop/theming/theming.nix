{
  den,
  lib,
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
  den.aspects.theming =
    { ... }:
    {
      imports = [
        {
          options = {
            colors = lib.mkOption {
              type = lib.types.anything;
              default = "test"; # osConfig.lib.base16.mkSchemeAttrs config.base16Scheme;
            };
            base16Scheme = lib.mkOption {
              type = lib.types.path;
              default = "${inputs.tt-schemes}/base24/chalk.yaml";
            };
          };
        }
      ];

      nixos =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            adw-gtk3
            adwaita-qt6
            dracula-icon-theme
            nordic
          ];
        };
    };
}
