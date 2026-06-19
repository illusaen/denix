{
  wlib,
  lib,
  config,
  ...
}:
{
  imports = [ wlib.wrapperModules.swaylock ];
  options = {
    font = lib.mkOption { type = lib.types.str; };
    colors = lib.mkOption { type = lib.types.raw; };
    image = lib.mkOption { type = lib.types.path; };
  };

  config.settings =
    let
      inherit (config.colors)
        base00
        base01
        base08
        base09
        base0B
        ;
    in
    {
      daemonize = true;
      ignore-empty-password = true;
      show-failed-attempts = true;
      indicator-idle-visible = true;
      indicator-radius = 128;
      indicator-thickness = 8;
      scaling = "center";
      font-size = 24;

      inherit (config) image font;

      inside-color = "${base01}00";
      inside-ver-color = "${base0B}dd";
      inside-wrong-color = "${base08}dd";
      ring-color = base09;
      key-hl-color = base0B;
      line-color = "${base00}00";
      separator-color = "${base00}00";
    };
}
