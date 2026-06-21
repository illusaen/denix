{lib, ...}: {
  den.aspects.base.nix-config = {
    nixos = {
      system.nixos.versionSuffix = lib.mkForce "";
      programs.nix-ld.enable = true;
    };

    os = {
      environment,
      pkgs,
      config,
      ...
    }: {
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        accept-flake-config = true;
        warn-dirty = false;
        trusted-users = [
          "root"
          "@wheel"
        ];
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

      time.timeZone = environment.timezone;

      security.sudo.extraConfig = ''
        Defaults lecture = never
      '';

      system.activationScripts.systemDiffNvd = {
        supportsDryActivation = true;
        text = ''
          if [[ -e /run/current-system ]]; then
              ${lib.getExe pkgs.nvd} --color=always --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig" || echo "FAILED TO GENERATE DIFF"
            fi
        '';
      };
    };
  };
}
