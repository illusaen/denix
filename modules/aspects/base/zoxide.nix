{
  den.aspects.base.zoxide = {
    shell = {
      interactiveShellInit = ''
        eval (zoxide init fish --cmd n | source)
      '';
    };

    persistUser.directories = [
      ".local/share/zoxide"
    ];

    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ zoxide ];
      };
  };
}
