{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.onepassword ];

  den.aspects.onepassword = {
    os = {
      programs._1password.enable = true;
      programs._1password-gui.enable = true;
    };

    hmLinux =
      { osConfig, ... }:
      {
        xdg.autostart.entries = [
          "${osConfig.programs._1password-gui.package}/share/applications/1password.desktop"
        ];
      };
  };
}
