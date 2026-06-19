{ inputs, ... }: {
  flake-file.inputs.nvf = {
    url = "github:NotAShelf/nvf";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.base.cli.nvf = {
    os = {
      imports = [ inputs.nvf.nixosModules.default ];

      nix.settings = {
        substituters = [
          "https://nvf.cachix.org"
        ];
        trusted-public-keys = [
          "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
        ];
      };

      programs.nvf = {
        enable = true;
      };
    };
  };
}
