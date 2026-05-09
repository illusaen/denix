{ den, lib, ... }:
{
  den.aspects.cli._.zoxide = den.lib.perHost {
    fish =
      { pkgs, ... }:
      {
        interactiveShellInit = ''
          eval (${lib.getExe pkgs.zoxide} init fish --cmd n | source)
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
