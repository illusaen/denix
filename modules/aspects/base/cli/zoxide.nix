{ den, ... }:
{
  den.aspects.base.cli.includes = with den.aspects.base.cli; [ zoxide ];

  den.aspects.base.cli.zoxide = {
    shell = {
      interactiveShellInit = ''
        eval (zoxide init fish --cmd n | source)
      '';
    };

    provides.to-users.persistUser.directories = [
      ".local/share/zoxide"
    ];

    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ zoxide ];
      };
  };
}
