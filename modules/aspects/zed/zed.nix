{ den, ... }:
{
  den.ctx.host.includes = [ den.aspects.zed ];
  den.aspects.zed = den.lib.perHost {
    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ zed-editor ];
      };

    hj = {
      xdg.config.files."zed/settings.json".source = ./settings.json;
    };
  };
}
