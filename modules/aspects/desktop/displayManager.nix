{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.gdm ];
  den.aspects.gdm.nixos = {
    services.displayManager = {
      enable = true;
      gdm = {
        enable = true;
        wayland = true;
      };
      autoLogin = {
        enable = true;
        user = "wendy";
      };
    };
  };
}
