{
  den.aspects.base.darwin-config = {
    darwin = {
      pkgs,
      lib,
      ...
    }: {
      system = {
        keyboard = {
          remapCapsLockToControl = true;
          enableKeyMapping = true;
        };
        defaults = {
          CustomUserPreferences = {
            "com.apple.desktopservices".DSDontWriteNetworkStores = true;
            "com.apple.desktopservices".DSDontWriteUSBStores = true;
            "com.apple.symbolichotkeys" = {
              AppleSymbolicHotKeys = {
              };
            };
          };

          NSGlobalDomain = {
            AppleIconAppearanceTheme = "ClearAutomatic";
            AppleShowAllExtensions = true;
            AppleShowAllFiles = true;
            AppleShowScrollBars = "Automatic";
            NSDocumentSaveNewDocumentsToCloud = false;
            "com.apple.mouse.tapBehavior" = 1;
          };
          dock = {
            wvous-bl-corner = 5;
            wvous-br-corner = 11;
            tilesize = 48;
            largesize = lib.mkDefault 72;
            magnification = true;
            minimize-to-application = true;
            orientation = "left";
            show-recents = false;
            static-only = true;
            autohide = true;
          };
          menuExtraClock = {
            ShowDayOfWeek = true;
            ShowDayOfMonth = true;
            ShowAMPM = true;
            ShowDate = 1;
            ShowSeconds = true;
          };

          finder = {
            AppleShowAllExtensions = true;
            AppleShowAllFiles = true;
            FXDefaultSearchScope = "SCcf";
            FXEnableExtensionChangeWarning = false;
            FXPreferredViewStyle = "clmv";
            NewWindowTarget = "Home";
            ShowStatusBar = true;
            ShowPathbar = true;
            _FXEnableColumnAutoSizing = true;
            _FXSortFoldersFirst = true;
          };

          SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
        };
      };
      security.pam.services.sudo_local = {
        touchIdAuth = true;
        watchIdAuth = true;
      };

      ids.gids.nixbld = 350;

      environment.systemPackages = with pkgs; [
        raycast
      ];

      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          cleanup = "zap";
          extraFlags = ["--force-cleanup"];
        };
        casks = [
          "raindropio"
          "colemak-dh"
        ];
      };
    };
  };
}
