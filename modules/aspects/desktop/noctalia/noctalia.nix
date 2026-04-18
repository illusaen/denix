{
  den,
  inputs,
  ...
}:
{
  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.desktop.includes = [ den.aspects.noctalia ];

  den.aspects.noctalia = den.lib.perHost {
    nixos =
      {
        pkgs,
        lib,
        inputs',
        ...
      }:
      let
        noctalia-cache-wallpaper = (pkgs.formats.json { }).generate "wallpapers.json" {
          defaultWallpaper = ../../../../resources/cube-dark.jpg;
        };

        noctalia-wrapped = pkgs.symlinkJoin {
          name = "noctalia-shell";
          paths = [ (inputs'.noctalia.packages.default.override { calendarSupport = true; }) ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            mkdir -p $out/cache
            install -Dm644 ${./settings.json} $out/settings.json
            install -Dm644 ${./colors.json} $out/colors.json
            install -Dm644 ${./plugins.json} $out/plugins.json
            install -Dm644 ${noctalia-cache-wallpaper} $out/cache/wallpapers.json
            wrapProgram $out/bin/noctalia-shell --set NOCTALIA_CONFIG_DIR $out --set NOCTALIA_CACHE_DIR $out/cache
          '';
        };

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
        imports = [ inputs.noctalia.nixosModules.default ];

        services.gnome.evolution-data-server.enable = true;
        security.pam.services.login.enableGnomeKeyring = true;

        nix.settings.extra-substituters = [ "https://noctalia.cachix.org" ];
        nix.settings.extra-trusted-public-keys = [
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];

        environment.systemPackages = [
          noctalia-diff
          noctalia-wrapped
        ];
      };

    persistUser.directories = [
      ".cache/noctalia"
      ".cache/noctalia-qs"
    ];
  };
}
