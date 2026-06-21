{
  den.aspects.programs.chat.telegram = {
    os = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [ayugram-desktop];
    };
  };
}
