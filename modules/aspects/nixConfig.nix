{ den, lib, ... }:
{
  den.ctx.host.includes = [
    den.aspects.nixConfig
  ];

  den.aspects.nixConfig = {
    includes = lib.attrValues den.aspects.nixConfig._;

    _.nix = den.lib.perHost {
      os.nix.settings = {
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
          "https://niri.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        ];
      };
    };

    _.nixpkgs = den.lib.perHost {
      os.nixpkgs.config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };

      nixos.home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        backupFileExtension = "backup";
        overwriteBackup = true;
      };
    };

    _.locale = den.lib.perHost {
      os.time.timeZone = "America/Chicago";
    };
  };
}
