{ den, lib, ... }:
{
  den.aspects.vscode = {
    includes = lib.attrValues den.aspects.vscode._;

    _.enable = den.lib.perHost {
      persistUser.directories = [
        ".config/Code"
        ".vscode/extensions"
      ];

      os =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [ vscode ];
        };
    };

    _.configure = den.lib.perUser (
      { host, ... }:
      {
        hjem =
          { pkgs, lib, ... }:
          let
            languageSnippets = { };
            globalSnippets = { };
            extensions =
              with pkgs.vscode-extensions;
              [
                jnoortheen.nix-ide
                mkhl.direnv
                dbaeumer.vscode-eslint
                rust-lang.rust-analyzer
                tamasfe.even-better-toml
                catppuccin.catppuccin-vsc-icons
                naumovs.color-highlight
                usernamehw.errorlens
                catppuccin.catppuccin-vsc
              ]
              ++ [
                (pkgs.vscode-utils.extensionFromVscodeMarketplace {
                  name = "treefmt-vscode";
                  publisher = "ibecker";
                  version = "2.4.1";
                  sha256 = "sha256-ZTRrZDXqK9L7E5fr5NLEa/0ZyTnFdItfytbVuh/qr94=";
                })
              ];
            seedbox-ip = "192.168.1.104";
            userSettings = {
              "direnv.restart.automatic" = true;
              "editor.defaultFormatter" = "ibecker.treefmt-vscode";
              "editor.fontLigatures" = "'ss01','ss05','dlig'";
              "editor.fontWeight" = "600";
              "editor.formatOnPaste" = true;
              "editor.formatOnSave" = true;
              "editor.lineHeight" = 1.2;
              "editor.minimap.enabled" = false;
              "editor.quickSuggestions".strings = "on";
              "editor.wordWrap" = "on";
              "editor.wordWrapColumn" = 120;
              "evenBetterToml.formatter.allowedBlankLines" = 1;
              "evenBetterToml.formatter.arrayAutoCollapse" = true;
              "evenBetterToml.formatter.arrayTrailingComma" = true;
              "evenBetterToml.formatter.columnWidth" = 120;
              "explorer.confirmDelete" = false;
              "explorer.confirmDragAndDrop" = false;
              "explorer.decorations.badges" = false;
              "files.associations"."*.css" = "tailwindcss";
              "files.autoSave" = "afterDelay";
              "git.autofetch" = true;
              "git.confirmSync" = false;
              "git.enableSmartCommit" = true;
              "nix.enableLanguageServer" = true;
              "nix.formatterPath" = "treefmt";
              "nix.hiddenLanguageServerErrors" = [
                "Request textDocument/definition failed."
              ];
              "[nix]" = {
                "editor.defaultFormatter" = "jnoortheen.nix-ide";
              };
              "[jsonc]" = {
                "editor.defaultFormatter" = "vscode.json-language-features";
              };
              "nix.serverPath" = "nixd";
              "nix.serverSettings".nixd.formatting.command = null;
              "remote.SSH.remotePlatform"."${seedbox-ip}" = "linux";
              "rust-analyzer.restartServerOnConfigChange" = true;
              "svelte.enable-ts-plugin" = true;
              "svelte.plugin.svelte.format.config.singleQuote" = true;
              "svelte.plugin.svelte.format.config.svelteStrictMode" = true;
              "terminal.integrated.defaultProfile.osx" = "fish";
              "terminal.integrated.profiles.osx".fish.path = "fish";
              "terminal.integrated.sendKeybindingsToShell" = true;
              "treefmt.command" = "$(which treefmt)";
              "#js/ts.inlayHints.enumMemberValues.enabled" = true;
              "window.titleBarStyle" = "custom";
              "workbench.iconTheme" = "catppuccin-macchiato";
              "workbench.sideBar.location" = "right";
              "workbench.startupEditor" = "none";
              "workbench.panel.defaultLocation" = "right";
              "update.mode" = "none";
              "extensions.autoCheckUpdates" = false;
              "editor.fontFamily" = host.fonts.mono.name;
              "editor.inlayHints.fontFamily" = host.fonts.mono.name;
              "editor.inlineSuggest.fontFamily" = host.fonts.mono.name;
              "scm.inputFontFamily" = host.fonts.mono.name;
              "debug.console.fontFamily" = host.fonts.mono.name;
              "markdown.preview.fontFamily" = host.fonts.sans.name;
              "chat.editor.fontFamily" = host.fonts.mono.name;
              "chat.fontFamily" = host.fonts.sans.name;
              "notebook.markup.fontFamily" = host.fonts.sans.name;

              # 4/3 factor used for pt to px;
              "editor.fontSize" = host.fonts.sizes.terminal * 4.0 / 3.0;
              "debug.console.fontSize" = host.fonts.sizes.terminal * 4.0 / 3.0;
              "markdown.preview.fontSize" = host.fonts.sizes.terminal * 4.0 / 3.0;
              "terminal.integrated.fontSize" = host.fonts.sizes.terminal * 4.0 / 3.0;
              "chat.editor.fontSize" = host.fonts.sizes.terminal * 4.0 / 3.0;

              # other factors (9/14, 13/14, 56/14) based on default for given value
              # divided by default for `editor.fontSize` (14) from
              # https://code.visualstudio.com/docs/getstarted/settings#_default-settings.
              "editor.minimap.sectionHeaderFontSize" = host.fonts.sizes.terminal * 4.0 / 3.0 * 9.0 / 14.0;
              "scm.inputFontSize" = host.fonts.sizes.terminal * 4.0 / 3.0 * 13.0 / 14.0;
              "screencastMode.fontSize" = host.fonts.sizes.terminal * 4.0 / 3.0 * 56.0 / 14.0;

              "workbench.colorTheme" = "Catppuccin Macchiato";
              "workbench.colorCustomizations" = {
                "[Catppuccin Macchiato]" = {
                  "titleBar.activeBackground" = "#242933";
                  "titleBar.inactiveBackground" = "#242933";
                  "editor.background" = "#242933";
                  "editorGutter.background" = "#242933";
                  "editorPane.background" = "#242933";
                  "editorGroupHeader.tabsBackground" = "#242933";
                  "editorOverviewRuler.background" = "#242933";
                  "breadcrumb.background" = "#242933";
                  "tab.activeBackground" = "#242933";
                  "tab.unfocusedActiveBackground" = "#242933";
                  "tab.selectedBackground" = "#242933";
                  "sideBar.background" = "#242933";
                  "sideBarSectionHeader.background" = "#242933";
                  "panel.background" = "#242933";
                  "statusBar.background" = "#242933";
                  "menu.background" = "#242933";
                  "commandCenter.background" = "#242933";
                  "commandCenter.activeBackground" = "#242933";
                  "commandCenter.debuggingBackground" = "#242933";
                  "scrollbar.background" = "#242933";
                  "scrollbarSlider.activeBackground" = "#242933";
                  "scrollbar.shadow" = "#242933";
                  "terminal.background" = "#242933";
                  "notifications.background" = "#242933";
                  "activityBar.background" = "#242933";
                };
              };
            };

            jsonFormat = pkgs.formats.json { };
            configDir = "Code";

            userDir =
              if pkgs.stdenv.isDarwin then
                "Library/Application Support/${configDir}/User"
              else
                ".config/${configDir}/User";
            extensionPath = ".vscode/extensions";
            extensionJson = ext: pkgs.vscode-utils.toExtensionJson ext;
            extensionDrv = pkgs.writeText "extensions-json" (extensionJson extensions);
          in
          {
            # systemd.services.vscode-extension-update = {
            #   description = "Regenerate VSCode extensions.json on change";
            #   restartTriggers = [ extensionDrv ];
            #   serviceConfig = {
            #     Type = "oneshot";
            #     ExecStart = pkgs.writeShellScript "update-vscode-extensions-json" ''
            #       run rm $VERBOSE_ARG -f ${extensionPath}/{extensions.json,.init-default-profile-extensions}
            #       verboseEcho "Regenerating VSCode extensions.json"
            #       run ${lib.getExe pkgs.vscode} --list-extensions > /dev/null
            #     '';
            #     RemainAfterExit = false;
            #   };
            #   wantedBy = [ "graphical-session.target" ];
            # };

            files = lib.mkMerge (
              lib.flatten [
                {
                  ".vscode/argv.json".text = builtins.toJSON {
                    password-store = "gnome-libsecret";
                    enable-crash-reporter = true;
                    crash-reporter-id = "d17b2c57-3182-4ec0-a09f-c8abd1812a80";
                  };
                }
                {
                  "${userDir}/settings.json".source = jsonFormat.generate "vscode-user-settings" userSettings;
                }

                (lib.mkIf (languageSnippets != { }) (
                  lib.mapAttrs' (
                    language: snippet:
                    lib.nameValuePair "${userDir}/snippets/${language}.json" {
                      source = jsonFormat.generate "user-snippet-${language}.json" snippet;
                    }
                  ) languageSnippets
                ))

                (lib.mkIf (globalSnippets != { }) {
                  "${userDir}/snippets/global.code-snippets".source =
                    jsonFormat.generate "user-snippet-global.code-snippets" globalSnippets;
                })

                (
                  let
                    # Adapted from https://discourse.nixos.org/t/vscode-extensions-setup/1801/2
                    subDir = "share/vscode/extensions";
                    toPaths =
                      ext:
                      map (k: { "${extensionPath}/${k}".source = "${ext}/${subDir}/${k}"; }) (
                        if ext ? vscodeExtUniqueId then
                          [ ext.vscodeExtUniqueId ]
                        else
                          builtins.attrNames (builtins.readDir (ext + "/${subDir}"))
                      );
                  in
                  # Mutable extensions dir can only occur when only default profile is set.
                  # Force regenerating extensions.json using the below method,
                  # causes VSCode to create the extensions.json with all the extensions
                  # in the extension directory, which includes extensions from other profiles.
                  lib.mkMerge (
                    (lib.concatMap toPaths extensions)
                    ++ [
                      {
                        # Whenever our immutable extensions.json changes, force VSCode to regenerate
                        # extensions.json with both mutable and immutable extensions.
                        "${extensionPath}/.extensions-immutable.json".source = extensionDrv;
                      }
                    ]
                  )
                )
              ]
            );
          };
      }
    );

  };
}
