{ den, ... }:
{
  den.policies.shell-to-fish =
    { host, ... }:
    (den.lib.policy.route {
      fromClass = "shell";
      intoClass = host.class;
      path = [
        "programs"
        "fish"
      ];
    });

  den.schema.host.includes = [ den.policies.shell-to-fish ];
  den.classes.shell.description = "Shell configuration class";

  den.aspects.base.cli.includes = with den.aspects.base.cli; [ fish ];

  den.aspects.base.cli.fish = {
    env.EDITOR = "vim";
    provides.to-users.persistUser.directories = [ ".local/share/fish" ];

    shell = {
      interactiveShellInit = ''
        set -gx OP_SERVICE_ACCOUNT_TOKEN (cat /etc/opnix-token | string collect)
      '';
    };

    os =
      {
        pkgs,
        self',
        ...
      }:
      {
        programs.bash.interactiveShellInit = ''
          # "check if parent process is not fish" && "make nested shells work properly"
          if grep -qv fish /proc/$PPID/comm && [[ $SHLVL == [12] ]]; then
              # set $SHELL for better integration with programs like nix shell, tmux, etc.
              SHELL=${pkgs.fish}/bin/fish exec fish
          fi
        '';
        programs.fish = {
          enable = true;
          interactiveShellInit = ''
            set -g fish_greeting ""
          '';
        };

        environment.shellAliases = {
          cd = "n";
          rmr = "rm -r";
          rmf = "rm -rf";
        };
        environment.systemPackages = with pkgs.fishPlugins; [
          puffer
          colored-man-pages
          self'.packages.fish-vendor-functions
        ];
      };

    nixos =
      { pkgs, ... }:
      {
        documentation.man.cache.enable = false;
        environment.systemPackages = with pkgs.fishPlugins; [
          fzf-fish
        ];
      };

    darwin = {
      documentation.man.enable = false;
      environment.shellInit = ''
        eval (/opt/homebrew/bin/brew shellenv)
      '';
    };
  };
}
