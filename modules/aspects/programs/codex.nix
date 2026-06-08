{ inputs, ... }: {
  flake-file.inputs.codex-desktop-linux = {
    url = "github:ilysenko/codex-desktop-linux";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.programs.codex = {
    env = { pkgs, lib, ... }: { CODEX_CLI_PATH = lib.getExe pkgs.codex; };
    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.codex-desktop-linux.nixosModules.default ];
        environment.systemPackages = with pkgs; [ codex ];
        programs.codexDesktopLinux = {
          enable = true;
          computerUseUi.enable = true;
          remoteMobileControl.enable = true;
          remoteControl.enable = true;
        };
      };

    darwin.homebrew.casks = [ "codex-app" ];
  };
}
