{
  den,
  inputs,
  rootPath,
  ...
}: {
  den.aspects.base.cli.shell-utils = {
    env.NIX_CONF = "~/Projects/denix";

    provides.to-users.persistUser.directories = [
      ".local/share/zoxide"
    ];

    wrapper-packages = {
      host,
      fleet,
      ...
    }: let
      wrapperDirectory = rootPath + /wrappers;
      inherit (den.users.registry.${host.system-owner}.identity) accountName email displayName;
    in {
      bat = {
        imports = [(wrapperDirectory + /bat/bat.nix)];
        renderScheme = fleet.my.base16.scheme.render;
      };

      custom-scripts = {
        imports = [(wrapperDirectory + /custom-scripts/custom-scripts.nix)];
        opnixPackage = inputs.opnix.packages.${host.system}.default;
      };

      eza = {
        wlib,
        pkgs,
        ...
      }: {
        imports = [wlib.modules.default];
        package = pkgs.eza;
        flags = {
          "--icons" = "auto";
          "--git" = true;
        };
      };

      fd = {
        wlib,
        pkgs,
        ...
      }: {
        imports = [wlib.modules.default];
        package = pkgs.fd;
        flags = {
          "--hidden" = true;
          "--follow" = true;
          "--exclude" = ".git";
        };
      };

      gh = {
        wlib,
        pkgs,
        config,
        ...
      }: {
        imports = [wlib.modules.default];
        env.GH_CONFIG_DIR = dirOf config.constructFiles.generatedConfig.path;
        package = pkgs.gh;
        constructFiles = {
          generatedConfig = {
            content = ''
              version: "1"
            '';
            relPath = "config.yml";
          };
          generatedHosts = {
            content = ''
              github.com:
                git_protocol: ssh
                users:
                  ${accountName}:
                user: ${accountName}
            '';
            relPath = "hosts.yml";
          };
        };
      };

      git = {
        imports = [(wrapperDirectory + /git.nix)];
        inherit accountName email displayName;
      };
    };

    os = {
      pkgs,
      config,
      lib,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        local.eza
        local.fd
        local.gh
        local.custom-scripts
        local.bat
        local.git
        zoxide
        coreutils
        fzf
      ];

      environment.shellAliases = {
        l = "eza -alg";
        ll = "eza --tree --git-ignore --all";
        cat = "bat";
        gst = "git status";
        gco = "git checkout";
        ga = "git add -A";
        gf = "git fetch";
        gl = "git pull";
        gd = "git diff";
        gb = "git branch";
        glg = "git log";
        gp = "git push";
        gpf = "git push --force-with-lease";
      };

      programs.fish.interactiveShellInit = ''
        eval (zoxide init fish --cmd n | source)
        abbr -a gcm --set-cursor 'git commit -m "%"'
        abbr -a git_clone_own_repo --set-cursor --regex "^g(gc|r)l\$" --function _git_clone_repo
      '';

      programs.direnv = {
        enable = true;
        silent = true;
        nix-direnv.enable = true;
        settings = {
          hide_env_diff = true;
          whitelist.prefix = ["~/Projects"];
        };
      };

      services.openssh.enable = true;
      programs.ssh.knownHosts =
        lib.mapAttrs'
        (
          name: publicKey:
            lib.nameValuePair "github.com/${name}" {
              inherit publicKey;
              hostNames = ["github.com"];
            }
        )
        {
          ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
          rsa = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
          dsa = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
        };

      environment.etc."dependencies.txt".text = lib.pipe config.environment.systemPackages (
        with builtins; [
          (lib.map (p: p.name))
          lib.lists.unique
          (sort lessThan)
          (concatStringsSep "\n")
        ]
      );

      system.userActivationScripts.rebuildBatCache = ''
        echo "Rebuilding bat cache."
        ${lib.getExe pkgs.local.bat} cache --build
      '';
    };
  };
}
