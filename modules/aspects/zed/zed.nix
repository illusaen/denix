{ den, inputs, ... }:
{
  flake-file.inputs.tinted-zed = {
    url = "github:tinted-theming/tinted-zed";
    flake = false;
  };

  den.ctx.host.includes = [ den.aspects.zed ];
  den.aspects.zed = den.lib.perHost {
    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          zed-editor
          codex
          codex-acp
        ];
      };

    hj =
      { pkgs, osConfig, ... }:
      let
        theme = osConfig.scheme {
          templateRepo = inputs.tinted-zed;
          target = "base16";
        };
      in
      {
        xdg.config.files = {
          "zed/settings.json".source = pkgs.replaceVars ./settings.json {
            sans = osConfig.myLib.fonts.sans.name;
            mono = osConfig.myLib.fonts.mono.name;
            theme-light = "Base16 ${osConfig.scheme.scheme-name}";
            theme-dark = "Base16 ${osConfig.scheme.scheme-name}";
          };
          "zed/themes/custom.json".source = theme;
        };
      };
  };
}
