{ den, lib, ... }:
{
  den.aspects.cli._.zoxide = den.lib.perHost {
    persistUser.files = [
      ".local/share/zoxide/db.zo"
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
