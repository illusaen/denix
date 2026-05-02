{ den, inputs, ... }:
{
  flake-file.inputs = {
    tinted-zed = {
      url = "github:tinted-theming/tinted-zed";
      flake = false;
    };
  };

  den.ctx.host.includes = [ den.aspects.zed ];
  den.aspects.zed = den.lib.perHost {
    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          zed-editor
          codex
          (stdenvNoCC.mkDerivation rec {
            pname = "codex-acp";
            version = "0.12.0";

            src = fetchurl {
              url = "https://github.com/zed-industries/codex-acp/releases/download/v${version}/codex-acp-${version}-x86_64-unknown-linux-musl.tar.gz";
              hash = "sha256-nJ/BN3qcWDTN16QsIftObg0nh8GFPRjv/nBxigkcpCo=";
            };

            sourceRoot = ".";

            installPhase = ''
              mkdir -p $out/bin
              install -m755 codex-acp $out/bin/codex-acp
            '';
          })
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

    persistUser.directories = [ ".local/share/zed" ];
  };
}
