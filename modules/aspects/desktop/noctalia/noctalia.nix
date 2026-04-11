{
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.desktop.includes = [ den.aspects.noctalia ];

  den.aspects.noctalia = {
    includes = lib.attrValues den.aspects.noctalia._;

    nixos =
      {
        pkgs,
        lib,
        ...
      }:
      let
        # Small application to easily show changed values from live noctalia settings
        noctalia-diff = pkgs.writeShellApplication {
          name = "noctalia-diff";
          runtimeInputs = [
            pkgs.bat-extras.batdiff
            pkgs.jq
          ];
          text = lib.replaceStrings [ "# syntax: bash\n" ] [ "" ] ''
            # syntax: bash
            batdiff <(jq -S . "$HOME/.config/noctalia/settings.json") \
            <(noctalia-shell ipc call state all | jq -S .settings)
          '';
        };
      in
      {
        services.gnome.evolution-data-server.enable = true;
        nix.settings.extra-substituters = [ "https://noctalia.cachix.org" ];
        nix.settings.extra-trusted-public-keys = [
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];
        environment.systemPackages = [
          noctalia-diff
        ];
      };

    hm =
      { inputs', ... }:
      {
        imports = [ inputs.noctalia.homeModules.default ];

        programs.noctalia-shell = {
          enable = true;
          package = inputs'.noctalia.packages.default.override { calendarSupport = true; };
        };
      };
  };
}
