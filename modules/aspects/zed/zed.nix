{ den, inputs, ... }:
{
  flake-file.inputs = {
    tinted-zed = {
      url = "github:tinted-theming/tinted-zed";
      flake = false;
    };
  };

  den.schema.host.includes = [ den.aspects.zed ];
  den.aspects.zed = {
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
      { pkgs, config, ... }:
      let
        theme = config.scheme {
          templateRepo = inputs.tinted-zed;
          target = "base16";
        };
      in
      {
        xdg.config.files = {
          "zed/settings.json".source = pkgs.replaceVars ./settings.json {
            sans = config.myLib.fonts.sans.name;
            mono = config.myLib.fonts.mono.name;
            theme-light = "Catppuccin Latte (Blur) [Heavy]";
            theme-dark = "Catppuccin Mocha (Blur) [Heavy]";
          };
          "zed/themes/custom.json".source = theme;
        };
      };

    persistUser.directories = [
      ".local/share/zed"
      ".codex"
    ];
  };
}
