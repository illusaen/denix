{ den, ... }:
{
  den.aspects.mac.includes = with den.aspects.mac; [ paneru ];

  den.aspects.mac.paneru = {
    darwin = {
      homebrew.brews = [ "paneru" ];
    };

    provides.to-users.hjem =
      { pkgs, user, ... }:
      {
        xdg.config.files."paneru/paneru.toml".source =
          (pkgs.formats.toml { }).generate "paneru-toml-${user.userName}"
            {
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
