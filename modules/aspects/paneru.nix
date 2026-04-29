{ den, inputs, ... }:
let
  settings = {
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
in
{
  flake-file.inputs.paneru = {
    url = "github:karinushka/paneru/main";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.paneru = den.lib.perHost {
    darwin = {
      imports = [ inputs.paneru.darwinModules.paneru ];
      services.paneru = {
        enable = true;
        inherit settings;
      };
    };

    hj =
      { pkgs, ... }:
      {
        xdg.config.files."paneru/paneru.toml".source =
          (pkgs.formats.toml { }).generate "paneru-toml"
            settings;
      };
  };
}
