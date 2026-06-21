{
  perSystem = {pkgs, ...}: {
    treefmt.programs.ruff = {
      check = true;
      format = true;
    };

    devshells.default = {
      packages = with pkgs; [python314];
    };
  };
}
