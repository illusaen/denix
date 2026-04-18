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

    _.enable = den.lib.perHost {
      persistUser.directories = [
        ".cache/noctalia"
      ];

      nixos =
        {
          pkgs,
          lib,
          inputs',
          ...
        }:
        let
          noctalia-plugins = pkgs.fetchFromGitHub {
            owner = "illusaen";
            repo = "noctalia-plugins";
            rev = "main";
            sha256 = "sha256-opJ3A0IVItbKupvis2MDBUzDg+7mh6UPeXwintmJ0mo=";
          };

          noctalia-wrapped = pkgs.symlinkJoin {
            name = "noctalia-shell";
            paths = [
              (inputs'.noctalia.packages.default.override { calendarSupport = true; })
              noctalia-plugins
            ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              mkdir -p $out/plugins
              mv $out/{keybind-cheatsheet,polkit-agent} $out/plugins/
              install -Dm644 ${./settings.json} $out/settings.json
              install -Dm644 ${./colors.json} $out/colors.json
              install -Dm644 ${./plugins.json} $out/plugins.json
              wrapProgram $out/bin/noctalia-shell --set NOCTALIA_CONFIG_DIR $out
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
              batdiff <(jq -S . "$NOCTALIA_CONFIG_DIR/settings.json") \
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

          environment.sessionVariables.NOCTALIA_CONFIG_DIR = "${noctalia-wrapped}";
          environment.systemPackages = [
            noctalia-diff
            noctalia-wrapped
          ];
        };
    };

    _.configure = den.lib.perUser {
      hjem =
        { pkgs, ... }:
        {
          files.".cache/noctalia/wallpapers.json".source =
            (pkgs.formats.json { }).generate "wallpapers.json"
              {
                defaultWallpaper = ../../../../resources/cube-dark.jpg;
              };
        };
    };
  };
}
