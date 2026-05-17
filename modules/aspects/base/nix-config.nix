{
  den,
  lib,
  inputs,
  ...
}:
let
  supportedSystems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];

  determinateNixd =
    system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    pkgs.stdenvNoCC.mkDerivation {
      pname = "determinate-nixd";
      inherit (inputs."determinate-nix-src".packages.${system}.default) version;

      src = inputs."determinate-nixd-${system}".outPath;
      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/determinate-nixd
        chmod +x $out/bin/determinate-nixd
      '';

      doInstallCheck = true;
      installCheckPhase = ''
        $out/bin/determinate-nixd --help
      '';
    };

  determinateInputs = {
    self = inputs.determinate // {
      packages = lib.genAttrs supportedSystems (system: {
        default = determinateNixd system;
      });
    };

    nix.packages = lib.genAttrs supportedSystems (system: {
      default = inputs."determinate-nix-src".packages.${system}.nix-cli;
    });
  };
in
{
  flake-file.inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  flake-file.inputs.determinate-nix-src.url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
  flake-file.inputs."determinate-nixd-x86_64-linux" = {
    url = "https://install.determinate.systems/determinate-nixd/tag/v3.20.0/x86_64-linux";
    flake = false;
  };
  flake-file.inputs."determinate-nixd-aarch64-darwin" = {
    url = "https://install.determinate.systems/determinate-nixd/tag/v3.20.0/macOS";
    flake = false;
  };

  den.aspects.base.includes = with den.aspects.base; [ nix-config ];

  den.aspects.base.nix-config = {
    nixos = {
      imports = [
        (import (inputs.determinate + "/modules/nixos.nix") determinateInputs)
      ];

      system.nixos.versionSuffix = lib.mkForce "";
      programs.nix-ld.enable = true;
    };

    os = {
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        warn-dirty = false;
        trusted-users = [ "@wheel" ];
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
          "https://nixpkgs-unfree.cachix.org"
          "https://illusaen.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
          "illusaen.cachix.org-1:fxa0K6z978YmVBWgy58TJp8qnw2XxWjC997ArJzzuxk="
        ];
      };

      nixpkgs.config.allowUnfree = true;

      time.timeZone = "America/Chicago";

      security.sudo.extraConfig = ''
        Defaults lecture = never
      '';
    };
  };
}
