hl.config({
  general = {
    border_size = 0,
    layout = "scrolling",
    resize_on_border = true,
    gaps_in = 8,
    gaps_out = 8,
  },
  decoration = {
    rounding = 12,
    inactive_opacity = 0.8,
    blur = {
      popups = true,
      size = 24,
      passes = 2,
      xray = false,
      new_optimizations = true,
    },
    shadow = {
      render_power = 2,
      range = 8,
      color = 0x50@base00@,
    },
  },
  animations = {
    workspace_wraparound = true,
  },
  input = {
    scroll_factor = 1.1,
    follow_mouse = 2,
    scroll_button = 274,
    scroll_method = "on_button_down",
    float_switch_override_focus = 0,
  },
  scrolling = {
    fullscreen_on_one_column = false,
    column_width = 0.333,
    explicit_column_widths = "0.333, 0.65, 0.9",
    focus_fit_method = 1,
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    initial_workspace_tracking = 1,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
  },
})
