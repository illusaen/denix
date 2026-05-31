{ den, rootPath, ... }:
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

    wrapper-packages =
      { host, ... }:
      {
        eza = rootPath + /wrappers/eza.nix;
        fd = rootPath + /wrappers/fd.nix;
        gh = {
          imports = [ (rootPath + /wrappers/gh.nix) ];
          inherit (den.users.registry.${host.system-owner}.identity) accountName;
        };
      };

    os =
      {
        pkgs,
        config,
        lib,
        self',
        ...
      }:
      {
        environment.systemPackages = with pkgs; [
          self'.packages.eza
          self'.packages.fd
          self'.packages.gh
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
