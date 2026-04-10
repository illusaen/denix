{
  den.aspects.noctalia.hm.programs.noctalia-shell.settings = {
    sessionMenu = {
      # UI settings
      position = "center";
      showHeader = true;
      showKeybinds = true;
      largeButtonsStyle = true;
      largeButtonsLayout = "grid";
      enableCountdown = true;
      countdownDuration = 10000;
      # Options
      powerOptions = [
        {
          action = "lock";
          command = "";
          countdownEnabled = true;
          enabled = true;
          keybind = "1";
        }
        {
          action = "logout";
          command = "";
          countdownEnabled = true;
          enabled = true;
          keybind = "2";
        }
        {
          action = "reboot";
          command = "";
          countdownEnabled = true;
          enabled = true;
          keybind = "3";
        }
        {
          action = "rebootToUefi";
          command = "";
          countdownEnabled = true;
          enabled = false;
          keybind = "4";
        }
      ];
    };
  };
}
