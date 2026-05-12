{
  den.aspects.darwin.paneru = {
    darwin.homebrew.brews = [
      {
        name = "paneru";
        restart_service = true;
      }
    ];

    provides.to-users.hjem =
      { pkgs, ... }:
      {
        xdg.config.files."paneru/paneru.toml" = {
          generator = pkgs.formats.toml { };
          value = {
            options = {
              mouse_follows_focus = true;
              preset_column_widths = [
                0.9
                0.75
              ];
            };
            bindings = {
              window_focus_west = "cmd - h";
              window_focus_east = "cmd - l";
              window_resize = "alt - r";
              window_center = "alt - c";
              quit = "ctrl + alt - q";
            };
          };
        };
      };
  };
}
