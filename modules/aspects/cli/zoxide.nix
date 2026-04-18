{ den, lib, ... }:
{
  den.aspects.cli._.zoxide = den.lib.perHost {
    persistUser.directories = [
      ".local/share/zoxide"
    ];

    os =
      { config, pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ zoxide ];
        programs.fish = lib.mkIf config.programs.fish.enable {
          interactiveShellInit = ''
            eval (${lib.getExe pkgs.zoxide} init fish --cmd n | source)
          '';
        };
      };
  };
}
