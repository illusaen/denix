{ den, ... }:
{
  den.ctx.host.includes = [
    den.aspects.nixConfig
  ];

  den.aspects.nixConfig = den.lib.perHost {
    os = {
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        warn-dirty = false;
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
          "https://nixpkgs-unfree.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        ];
      };

      nixpkgs.config = {
        allowUnfree = true;
      };

      # nixpkgs.overlays = [ (import ../flake/_overlays.nix) ];

      time.timeZone = "America/Chicago";
    };
  };
}
