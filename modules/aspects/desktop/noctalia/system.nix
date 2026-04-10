{
  den.aspects.noctalia.hm.programs.noctalia-shell.settings = {
    network = {
      # --Settings--
      # Wi-Fi
      wifiEnabled = true;
      airplaneModeEnabled = false;
      # Bluetooth
      bluetoothAutoConnect = false;
      disableDiscoverability = false;
      bluetoothRssiPollingEnabled = false;
      bluetoothRssiPollIntervalMs = 60000;
      bluetoothHideUnnamedDevices = false;

      # --UI--
      networkPanelView = "wifi";
      # Wi-Fi
      wifiDetailsViewMode = "grid";
      # Bluetooth
      bluetoothDetailsViewMode = "grid";
    };

    # ---Noctalia audio settings---
    audio = {
      # Volume
      volumeStep = 5;
      volumeOverdrive = true;
      volumeFeedback = false;
      volumeFeedbackSoundFile = "";
      # Media
      preferredPlayer = "";
      mprisBlacklist = [ ];
      #Visualiser
      spectrumFrameRate = 30;
      visualizerType = "linear";
    };

    # ---Noctalia brightness settings---
    brightness = {
      brightnessStep = 5;
      enforceMinimum = true;
      enableDdcSupport = false; # External display brightness control
      backlightDeviceMappings = [ ];
    };

    # ---Noctalia location settings---
    location = {
      # Weather
      name = "Chicago";
      weatherEnabled = true;
      weatherShowEffects = true;
      useFahrenheit = false;
      # Calendar
      showWeekNumberInCalendar = true;
      showCalendarEvents = true;
      showCalendarWeather = true;
      analogClockInCalendar = false;
      firstDayOfWeek = 1;
      # Location UI
      use12hourFormat = true;
      hideWeatherTimezone = false; # Hide details in UI?
      hideWeatherCityName = true; # Hide details in UI?
    };

    # ---Noctalia performance settings---
    noctaliaPerformance = {
      disableWallpaper = true;
      disableDesktopWidgets = true;
    };

    # ---Noctalia hooks settings---
    hooks = {
      enabled = false;
      startup = ""; # Niri startup completed
      session = ""; # Shutdown/Reboot
      wallpaperChange = "";
      darkModeChange = "";
      colorGeneration = "";
      screenLock = "";
      screenUnlock = "";
      performanceModeEnabled = "";
      performanceModeDisabled = "";
    };

    # ---Noctalia system monitor settings---
    systemMonitor = {
      # Colour config
      useCustomColors = false;
      warningColor = "";
      criticalColor = "";
      # CPU
      cpuWarningThreshold = 80;
      cpuCriticalThreshold = 90;
      # Temp
      tempWarningThreshold = 80;
      tempCriticalThreshold = 90;
      # GPU
      enableDgpuMonitoring = false;
      gpuWarningThreshold = 80;
      gpuCriticalThreshold = 90;
      # RAM
      memWarningThreshold = 80;
      memCriticalThreshold = 90;
      # Swap
      swapWarningThreshold = 80;
      swapCriticalThreshold = 90;
      # Disk
      diskWarningThreshold = 80;
      diskCriticalThreshold = 90;
      diskAvailWarningThreshold = 20;
      diskAvailCriticalThreshold = 10;
      # External system monitor program
      externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
    };
  };
}
