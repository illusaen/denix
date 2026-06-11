{
  wlib,
  pkgs,
  ...
}:
let
  display = status: "niri msg action power-${status}-monitors";
in
{
  imports = [ wlib.wrapperModules.swayidle ];
  options = {
    # niriExecutable = lib.mkOption { type = lib.types.package; };
  };

  config.events.after-resume = display "on";
  config.timeouts = [
    {
      timeout = 15; # in seconds
      command = "${pkgs.libnotify}/bin/notify-send 'Turning off monitors in 5 seconds' -t 5000";
    }
    {
      timeout = 25;
      command = display "off";
    }
  ];
}
