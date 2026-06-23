{colors}: {
  gaps = 14;
  struts = {
    left = 8;
    right = 8;
    top = 0;
    bottom = 0;
  };
  background-color = "transparent";
  focus-ring.off = _: {};
  border.off = _: {};
  shadow = {
    on = _: {};
    softness = 28;
    spread = 4;
    offset = _: {
      props = {
        x = 0;
        y = 8;
      };
    };
    color = "${colors.base00}66";
  };
  center-focused-column = "on-overflow";
  default-column-width.proportion = 0.333;
  preset-column-widths = [
    {proportion = 0.333;}
    {proportion = 0.667;}
  ];
  tab-indicator = {
    hide-when-single-tab = _: {};
    gap = 2;
    width = 4;
    active-gradient = _: {
      props = {
        from = colors.base0C;
        to = colors.base15;
      };
    };
    inactive-gradient = _: {
      props = {
        from = colors.base02;
        to = colors.base03;
        relative-to = "workspace-view";
      };
    };
    urgent-gradient = _: {
      props = {
        from = colors.base08;
        to = colors.base12;
      };
    };
  };
}
