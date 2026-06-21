{den, ...}: {
  den.aspects.display-manager = {
    includes = with den.aspects.display-manager; [
      swaync
      regreet
      niri
      waybar
      hide-desktop-entries
      monitor
      paneru
      rofi
      swayidle
      swaylock
    ];
  };
}
