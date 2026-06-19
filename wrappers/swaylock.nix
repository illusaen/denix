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
    with config.colors;
    let
      inside = base00;
      ring = base09;
      text = base05;
      positive = base0B;
      negative = base08;
      transparent = "${base00}00";
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

      color = inside;
      inside-color = transparent;
      inside-clear-color = inside;
      inside-caps-lock-color = inside;
      inside-ver-color = inside;
      inside-wrong-color = inside;
      key-hl-color = positive;
      layout-bg-color = inside;
      layout-border-color = ring;
      layout-text-color = text;
      ring-color = ring;
      ring-clear-color = negative;
      ring-caps-lock-color = ring;
      ring-ver-color = positive;
      ring-wrong-color = negative;
      separator-color = transparent;
      text-color = text;
      text-clear-color = text;
      text-caps-lock-color = text;
      text-ver-color = text;
      text-wrong-color = text;
    };
}
