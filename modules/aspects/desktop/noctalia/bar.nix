{ lib, ... }:
{
  den.aspects.noctalia.hm.programs.noctalia-shell.settings = {
    # ---Noctalia bar settings---
    bar = {
      barType = "simple";
      position = "top";
      monitors = [ "DP-2" ];
      screenOverrides = [ ];
      backgroundOpacity = lib.mkForce 0;
      density = "spacious";
      showOutline = false;
      showCapsule = false;
      capsuleColorKey = "none";
      widgetSpacing = 16;
      contentPadding = 8;
      fontScale = 1.1;
      useSeparateOpacity = true;
      floating = false;
      marginVertical = 4;
      marginHorizontal = 4;
      frameThickness = 8;
      frameRadius = 12;
      enableExclusionZoneInset = false;
      outerCorners = false;
      hideOnOverview = true;
      displayMode = "always_visible";
      autoHideDelay = 500;
      autoShowDelay = 150;
      showOnWorkspaceSwitch = true;
      # Actions
      rightClickAction = "controlCenter";
      rightClickCommand = "";
      rightClickFollowMouse = true;
      middleClickAction = "none";
      middleClickCommand = "";
      middleClickFollowMouse = true;
      mouseWheelAction = "none";
      mouseWheelWrap = true;
      reverseScroll = false;
      widgets = {
        left = [
          {
            id = "SessionMenu";
            iconColor = "none";
          }
          {
            id = "ActiveWindow";
            colorizeIcons = false;
            hideMode = "hidden";
            maxWidth = 480;
            scrollingMode = "hover";
            showIcon = true;
            textColor = "none";
            useFixedWidth = false;
          }
        ];
        center = [
          {
            id = "Workspace";
            characterCount = 2;
            colorizeIcons = false;
            emptyColor = "secondary";
            enableScrollWheel = true;
            focusedColor = "primary";
            followFocusedScreen = true;
            groupedBorderOpacity = 0.5;
            hideUnoccupied = true;
            iconScale = 1;
            fontWeight = "bold";
            labelMode = "index";
            occupiedColor = "secondary";
            pillSize = 0.6;
            showApplications = true;
            showApplicationsHover = false;
            showBadge = true;
            showLabelsOnlyWhenOccupied = true;
            unfocusedIconsOpacity = 0.8;
          }
        ];
        right = [
          {
            id = "MediaMini";
            compactMode = false;
            hideMode = "idle";
            hideWhenIdle = false;
            maxWidth = 480;
            panelShowAlbumArt = true;
            scrollingMode = "always";
            showAlbumArt = false;
            showArtistFirst = true;
            showProgressRing = true;
            showVisualizer = true;
            textColor = "none";
            useFixedWidth = false;
            visualizerType = "wave";
          }
          {
            id = "Volume";
            displayMode = "onhover";
            iconColor = "none";
            middleClickCommand = "pwvucontrol || pavucontrol";
            textColor = "none";
          }
          {
            id = "Clock";
            clockColor = "none";
            customFont = "";
            formatHorizontal = "ddd MMM d, hh:mm AP";
            formatVertical = "HH mm";
            tooltipFormat = "dddd MMMM d, hh:mm AP";
            useCustomFont = false;
          }
          {
            id = "SystemMonitor";
            compactMode = true;
            diskPath = "/";
            iconColor = "none";
            showCpuUsage = true;
            showCpuCores = false;
            showCpuFreq = false;
            showCpuTemp = false;
            showDiskAvailable = false;
            showDiskUsage = false;
            showDiskUsageAsPercent = false;
            showGpuTemp = false;
            showLoadAverage = false;
            showMemoryAsPercent = true;
            showMemoryUsage = true;
            showNetworkStats = false;
            showSwapUsage = false;
            textColor = "none";
            useMonospaceFont = true;
            usePadding = false;
          }
          {
            id = "NotificationHistory";
            hideWhenZero = true;
            hideWhenZeroUnread = false;
            iconColor = "none";
            showUnreadBadge = true;
            unreadBadgeColor = "primary";
          }
          {
            id = "Tray";
            blacklist = [ ];
            chevronColor = "none";
            colorizeIcons = true;
            drawerEnabled = true;
            hidePassive = false;
          }
        ];
      };
    };
  };
}
