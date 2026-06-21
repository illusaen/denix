{
  cursor,
  highlightColor,
}: {
  screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
  prefer-no-csd = _: {};
  hotkey-overlay = {
    skip-at-startup = _: {};
  };
  cursor = {
    xcursor-theme = "${cursor.name}";
    xcursor-size = cursor.size;
  };
  input = {
    mouse = {
      middle-emulation = _: {};
      scroll-button = 274;
      scroll-method = "on-button-down";
      scroll-factor = 1.1;
    };
    warp-mouse-to-focus = _: {};
  };
  debug.wait-for-frame-completion-before-queueing = _: {};
  recent-windows = {
    previews = {
      max-height = 1080;
      max-scale = 0.75;
    };
    highlight = {
      active-color = "${highlightColor}ff";
      padding = 30;
      corner-radius = 12;
    };
    binds = {
      "Alt+Tab".next-window = _: {};
      "Alt+Shift+Tab".previous-window = {};
      "Alt+grave".next-window = _: {props.filter = "app-id";};
      "Alt+Shift+grave".previous-window = _: {props.filter = "app-id";};
    };
  };
  animations = {
    screenshot-ui-open = {
      duration-ms = 200;
      curve = "ease-out-quad";
    };
    window-open = {
      duration-ms = 150;
      curve = "ease-out-expo";
    };
    window-close = {
      duration-ms = 150;
      curve = "ease-out-quad";
    };

    workspace-switch = {
      spring = _: {
        props = {
          damping-ratio = 0.65;
          stiffness = 1000;
          epsilon = 0.0001;
        };
      };
    };
    horizontal-view-movement = {
      spring = _: {
        props = {
          damping-ratio = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
    };
    window-movement = {
      spring = _: {
        props = {
          damping-ratio = 0.8;
          stiffness = 1000;
          epsilon = 0.0001;
        };
      };
    };
    window-resize = {
      spring = _: {
        props = {
          damping-ratio = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
    };
    config-notification-open-close = {
      spring = _: {
        props = {
          damping-ratio = 0.6;
          stiffness = 1000;
          epsilon = 0.001;
        };
      };
    };
    exit-confirmation-open-close = {
      spring = _: {
        props = {
          damping-ratio = 0.6;
          stiffness = 500;
          epsilon = 0.01;
        };
      };
    };
    overview-open-close = {
      spring = _: {
        props = {
          damping-ratio = 1.0;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
    };
    recent-windows-close = {
      spring = _: {
        props = {
          damping-ratio = 1.0;
          stiffness = 800;
          epsilon = 0.001;
        };
      };
    };
  };
}
