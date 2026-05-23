{ den, inputs, ... }:
{
  den.policies.env-to-os =
    { host, ... }:
    (den.lib.policy.route {
      fromClass = "env";
      intoClass = host.class;
      path = [
        "environment"
        (if host.class == "nixos" then "sessionVariables" else "variables")
      ];
      guard =
        _:
        builtins.elem host.class [
          "nixos"
          "darwin"
        ];
    });

  den.schema.host.includes = [ den.policies.env-to-os ];
  den.classes.env.description = "Environment variables class";

  den.aspects.base.includes = [ den.aspects.base.cli ];
  den.aspects.base.cli.includes = with den.aspects.base.cli; [ shell-utils ];

  den.aspects.base.cli.shell-utils = {
    env.NIX_CONF = "~/Projects/denix";

    shell = {
      shellAliases = {
        l = "eza -alg";
        ll = "eza --tree --git-ignore --all";
      };
      interactiveShellInit = ''
        eval (zoxide init fish --cmd n | source)
      '';
    };

    provides.to-users.persistUser.directories = [
      ".local/share/zoxide"
    ];

    os =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      let
        eza-wrapped = inputs.wrappers.lib.wrapPackage (_: {
          inherit pkgs; # you can only grab the final package if you supply pkgs!
          package = pkgs.eza;
          flags = {
            "--icons" = "auto";
            "--git" = true;
          };
        });
        fd-wrapped = inputs.wrappers.lib.wrapPackage (_: {
          inherit pkgs; # you can only grab the final package if you supply pkgs!
          package = pkgs.fd;
          flags = {
            "--hidden" = true;
            "--follow" = true;
            "--exclude" = ".git";
          };
        });
        gh-wrapped = inputs.wrappers.lib.wrapPackage (
          { config, ... }:
          {
            inherit pkgs; # you can only grab the final package if you supply pkgs!
            package = pkgs.gh;
            env.GH_CONFIG_DIR = dirOf config.constructFiles.generatedConfig.path;
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
                      illusaen:
                    user: illusaen
                '';
                relPath = "hosts.yml";
              };
            };
          }
        );
      in
      {
        environment.systemPackages = with pkgs; [
          eza-wrapped
          fd-wrapped
          gh-wrapped
          zoxide
          coreutils
          vim
          fzf
        ];

        environment.etc."dependencies.txt".text = lib.pipe config.environment.systemPackages (
          with builtins;
          [
            (lib.map (p: p.name))
            lib.lists.unique
            (sort lessThan)
            (concatStringsSep "\n")
          ]
        );
      };
  };
}
