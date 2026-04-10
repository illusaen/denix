{
  den.aspects.noctalia.hm.programs.noctalia-shell.settings = {
    notifications = {
      enabled = true;
      # Appearance
      density = "default";
      location = "top_right";
      overlayLayer = true; # Show notifications above fullscreen windows
      backgroundOpacity = 0.9;
      monitors = [ ]; # Show notifications only on specific monitors
      # Timeout
      respectExpireTimeout = false;
      lowUrgencyDuration = 3;
      normalUrgencyDuration = 8;
      criticalUrgencyDuration = 15;
      # History
      clearDismissed = true;
      enableMarkdown = false;
      saveToHistory = {
        low = true;
        normal = true;
        critical = true;
      };
      # Sound
      sounds = {
        enabled = false;
        volume = 0.5;
        separateSounds = false;
        criticalSoundFile = "";
        normalSoundFile = "";
        lowSoundFile = "";
        excludedApps = "discord,firefox,chrome,chromium,edge";
      };
      # Toast
      enableMediaToast = false;
      enableKeyboardLayoutToast = true;
      enableBatteryToast = true;
    };
  };
}
