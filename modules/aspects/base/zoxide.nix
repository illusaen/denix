{
  den.aspects.base.zoxide = {
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
