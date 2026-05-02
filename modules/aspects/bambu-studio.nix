{ den, ... }:
{
  perSystem =
    { pkgs, ... }:
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
        environment.systemPackages = with pkgs; [ bambu-studio ];
      };
  };
}
