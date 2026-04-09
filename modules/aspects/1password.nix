{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.onepassword ];

  den.aspects.onepassword = {
    os = {
      programs._1password.enable = true;
      programs._1password-gui.enable = true;
    };
  };
}
