{
  den.aspects.base.cli.fish = {
    env.EDITOR = "nvim";
    provides.to-users.persistUser.directories = [".local/share/fish"];

    os = {pkgs, ...}: {
      programs.bash.interactiveShellInit = ''
        # "check if parent process is not fish" && "make nested shells work properly"
        if grep -qv fish /proc/$PPID/comm && [[ $SHLVL == [12] ]]; then
            # set $SHELL for better integration with programs like nix shell, tmux, etc.
            SHELL=${pkgs.fish}/bin/fish exec fish
        fi
      '';
      programs.fish = {
        enable = true;
        generateCompletions = false;
        interactiveShellInit = ''
          set -g fish_greeting ""
          set -gx OP_SERVICE_ACCOUNT_TOKEN (cat /etc/opnix-token | string collect)
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
        pkgs.local.fish-scripts
      ];
    };

    nixos = {pkgs, ...}: {
      documentation.man.cache.enable = false;
      documentation.man.cache.generateAtRuntime = false;
      environment.systemPackages = with pkgs.fishPlugins; [
        fzf-fish
      ];
    };

    darwin = {
      documentation.man.enable = false;
      programs.fish.interactiveShellInit = ''
        /opt/homebrew/bin/brew shellenv | source
      '';
    };
  };
}
