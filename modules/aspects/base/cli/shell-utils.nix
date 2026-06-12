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

  den.aspects.base.cli.shell-utils = {
    env.NIX_CONF = "~/Projects/denix";

    provides.to-users.persistUser.directories = [
      ".local/share/zoxide"
    ];

    wrapper-packages =
      { host, ... }:
      let
        wrapperDirectory = rootPath + "/wrappers";
      in
      {
        eza = wrapperDirectory + /eza.nix;
        fd = wrapperDirectory + /fd.nix;
        gh = {
          imports = [ (wrapperDirectory + /gh.nix) ];
          inherit (den.users.registry.${host.system-owner}.identity) accountName;
        };
      };

    os =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      {
        environment.systemPackages = with pkgs; [
          local.eza
          local.fd
          local.gh
          zoxide
          coreutils
          vim
          fzf
        ];

        environment.shellAliases = {
          l = "eza -alg";
          ll = "eza --tree --git-ignore --all";
        };
        programs.fish.interactiveShellInit = ''
          eval (zoxide init fish --cmd n | source)
        '';

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
