{
  den,
  ...
}:
{
  den.aspects.desktop.includes = [ den.aspects.niri ];

  den.aspects.niri = den.lib.perHost {
    nixos =
      { pkgs, lib, ... }:
      let
        kdlConfig = pkgs.writeText "niri-config-kdl" (
          builtins.readFile ./config.kdl
          + ''
            spawn-at-startup "sh" "-c" "noctalia-shell"
            xwayland-satellite { path "${lib.getExe pkgs.xwayland-satellite}"; }
          ''
        );
      in
      {
        nix.settings.extra-substituters = [ "https://niri.cachix.org" ];
        nix.settings.extra-trusted-public-keys = [
          "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        ];

        programs.niri.enable = true;

        systemd.user.services = {
          niri-flake-polkit.enable = lib.mkDefault false;
          delayed-startup = {
            wantedBy = [ "default.target" ];
            description = "Delayed startup of programs in xdg autostart that have NotShowIn=niri attr";
            script = ''
              ${pkgs.coreutils}/bin/sleep 1
              for file in $HOME/.config/autostart/*.desktop; do
                if ${pkgs.gnugrep}/bin/grep -q "NotShowIn=.*niri" "$file"; then
                  echo "Starting $file"
                  ${pkgs.dex}/bin/dex "$file"
                fi
              done
            '';
          };
        };
        services.displayManager.defaultSession = "niri";

        environment.systemPackages = with pkgs; [
          xwayland-satellite
        ];

        environment.etc."niri/config.kdl".source = kdlConfig;
      };
  };
}
