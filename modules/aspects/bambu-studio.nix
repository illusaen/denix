{ den, self, ... }:
{
  perSystem =
    {
      system,
      inputs',
      ...
    }:
    let
      pkgs = import inputs'.nixpkgs.legacyPackages.path {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      packages.bambu-studio = pkgs.bambu-studio;
    };

  flake.overlays.default = final: prev: {
    bambu-studio = prev.bambu-studio.overrideAttrs (_old: rec {
      version = "2.06.00.51";
      src = final.fetchFromGitHub {
        owner = "bambulab";
        repo = "BambuStudio";
        tag = "v${version}";
        hash = "sha256-jLaSUs6OmoD0yw1hOcJarYKfr1rbhB2TwRiBBU0utEI=";
      };
    });
  };

  den.aspects.bambu-studio = den.lib.perHost {
    nixos =
      { pkgs, ... }:
      {
        nixpkgs.overlays = [ self.overlays.default ];
        environment.systemPackages = with pkgs; [ bambu-studio ];
      };
  };
}
