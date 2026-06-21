{
  config,
  wlib,
  lib,
  pkgs,
  ...
}: {
  imports = [wlib.modules.default];
  options = {
    renderScheme = lib.mkOption {
      type = lib.types.raw;
      description = "base16 scheme renderer";
    };
    font = lib.mkOption {
      type = lib.types.submodule {
        options = {
          name = lib.mkOption {type = lib.types.str;};
          size = lib.mkOption {type = lib.types.int;};
        };
      };
    };
    shell.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fish;
    };
  };
  config.package =
    if pkgs.stdenv.isDarwin
    then pkgs.ghostty-bin
    else pkgs.ghostty;
  config.flags."--config-file" = {
    data = config.constructFiles.generatedConfig.path;
    sep = "=";
  };
  config.constructFiles = {
    generatedConfig = {
      content = ''
        font-family = ${config.font.name}
        font-size = ${toString config.font.size}

        background-opacity = 0.9
        background-opacity-cells = true
        background-blur = macos-glass-regular

        window-padding-x = 16
        window-padding-y = 16
        window-padding-balance = true

        macos-hidden = always

        command = ${lib.getExe config.shell.package}
        keybind = global:cmd+backquote=toggle_quick_terminal
        quit-after-last-window-closed = false
        theme = ${config.constructFiles.themeConfig.path}
      '';
      relPath = "config.ghostty";
    };
    themeConfig = let
      ghostty-theme = config.renderScheme {
        inherit pkgs lib;
        template = ./ghostty.theme.mustache;
        extension = "ghostty";
      };
    in {
      relPath = "Cosmic.ghostty";
      builder = ''
        mkdir -p "$(dirname "$2")"
        ln -s ${lib.escapeShellArg ghostty-theme} "$2"
      '';
    };
  };
}
