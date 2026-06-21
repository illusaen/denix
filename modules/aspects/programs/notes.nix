{
  den.aspects.programs.notes = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [obsidian];
    };
  };
}
