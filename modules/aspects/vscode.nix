{ den, lib, ... }:
{
  den.aspects.vscode = {
    includes = lib.attrValues den.aspects.vscode._;

    _.enable = den.lib.perHost {
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
            colorCustomizationAttrs = [
              "titleBar.activeBackground"
              "titleBar.inactiveBackground"
              "editor.background"
              "editorGutter.background"
              "editorPane.background"
              "editorGroupHeader.tabsBackground"
              "editorOverviewRuler.background"
              "breadcrumb.background"
              "tab.activeBackground"
              "tab.unfocusedActiveBackground"
              "tab.selectedBackground"
              "sideBar.background"
              "sideBarSectionHeader.background"
              "panel.background"
              "statusBar.background"
              "menu.background"
              "commandCenter.background"
              "commandCenter.activeBackground"
              "commandCenter.debuggingBackground"
              "scrollbar.background"
              "scrollbarSlider.activeBackground"
              "scrollbar.shadow"
              "terminal.background"
              "notifications.background"
              "activityBar.background"
            ];
            customizeAttrs =
              attrs: value:
              lib.pipe attrs [
                (map (v: (lib.nameValuePair v value)))
                builtins.listToAttrs
              ];
            languageSnippets = {
              nix."Den Aspect" = {
                prefix = [
                  "den"
                  "aspect"
                ];
                body = [
                  "{ den, ...}:"
                  "{"
                  "\tden.ctx.\${1:host}.includes = [ den.aspects.\${2:name} ];"
                  "\tden.aspects.\${3:name} = den.lib.per\${4:Host} {"
                  "\t\t\$0"
                  "\t};"
                  "}"
                ];
                description = "Den aspect snippet";
              };
            };
            extensions =
              with pkgs.vscode-extensions;
              [
                jnoortheen.nix-ide
                mkhl.direnv
                dbaeumer.vscode-eslint
                rust-lang.rust-analyzer
                tamasfe.even-better-toml
                naumovs.color-highlight
                usernamehw.errorlens
                svelte.svelte-vscode
                bradlc.vscode-tailwindcss
              ]
              ++ [
                (pkgs.vscode-utils.extensionFromVscodeMarketplace {
                  name = "treefmt-vscode";
                  publisher = "ibecker";
                  version = "2.4.1";
                  sha256 = "sha256-ZTRrZDXqK9L7E5fr5NLEa/0ZyTnFdItfytbVuh/qr94=";
                })
                (pkgs.vscode-utils.extensionFromVscodeMarketplace {
                  name = "one-monokai";
                  publisher = "azemoh";
                  version = "0.5.2";
                  sha256 = "sha256-lky8hF5h/VIIEecS+zjoTLhyWwWC0axNnIgnkPJAnOA=";
                })
                (pkgs.vscode-utils.extensionFromVscodeMarketplace {
                  name = "chatgpt";
                  publisher = "openai";
                  version = "26.5415.20818";
                  sha256 = "sha256-Sr+qt5jsxjQ43GJarnXPMPMsxiPR7kmfthtbtYCEaHs=";
                })
              ];
            userSettings = {
              direnv.restart.automatic = true;
              editor = {
                defaultFormatter = "ibecker.treefmt-vscode";
                fontLigatures = "'ss01','ss05','dlig'";
                fontWeight = "600";
                formatOnPaste = true;
                formatOnSave = true;
                lineHeight = 1.2;
                minimap.enabled = false;
                quickSuggestions.strings = "on";
                wordWrap = "on";
                wordWrapColumn = 120;
              };
              evenBetterToml.formatter = {
                allowedBlankLines = 1;
                arrayAutoCollapse = true;
                arrayTrailingComma = true;
                columnWidth = 120;
              };
              explorer = {
                confirmDelete = false;
                confirmDragAndDrop = false;
                decorations.badges = false;
              };
              files = {
                associations."*.css" = "tailwindcss";
                autoSave = "afterDelay";
              };
              git = {
                autofetch = true;
                confirmSync = false;
                enableSmartCommit = true;
              };
              nix = {
                enableLanguageServer = true;
                formatterPath = "treefmt";
                hiddenLanguageServerErrors = [ "Request textDocument/definition failed." ];
                serverPath = "nixd";
                serverSettings.nixd.formatting.command = null;
              };
              "[nix]".editor.defaultFormatter = "jnoortheen.nix-ide";
              "[jsonc]".editor.defaultFormatter = "vscode.json-language-features";
              rust-analyzer.restartServerOnConfigChange = true;
              svelte = {
                enable-ts-plugin = true;
                plugin.svelte.format.config.singleQuote = true;
                plugin.svelte.format.config.svelteStrictMode = true;
              };
              terminal.integrated = {
                defaultProfile.osx = "fish";
                profiles.osx.fish.path = "fish";
                sendKeybindingsToShell = true;
              };
              workbench = {
                colorTheme = "One Monokai";
                iconTheme = "catppuccin-macchiato";
                sideBar.location = "right";
                startupEditor = "none";
                panel.defaultLocation = "right";
                colorCustomizations = lib.mergeAttrsList [
                  { "[Catppuccin Macchiato]" = customizeAttrs colorCustomizationAttrs "#242933"; }
                  { "[Nord]" = customizeAttrs colorCustomizationAttrs "#242933"; }
                  { "[One Monokai]" = customizeAttrs colorCustomizationAttrs "#21252b"; }
                ];
              };
              treefmt.command = "$(which treefmt)";
              "#js/ts".inlayHints.enumMemberValues.enabled = true;
              window.titleBarStyle = "custom";
              update.mode = "none";
              extensions.autoCheckUpdates = false;
            }
            // (customizeAttrs [
              "editor.fontSize"
              "debug.console.fontSize"
              "markdown.preview.fontSize"
              "terminal.integrated.fontSize"
              "chat.editor.fontSize"
            ] (host.fonts.sizes.terminal * 4.0 / 3.0))
            // (customizeAttrs [
              "editor.fontFamily"
              "editor.inlayHints.fontFamily"
              "editor.inlineSuggest.fontFamily"
              "scm.inputFontFamily"
              "debug.console.fontFamily"
              "chat.editor.fontFamily"
            ] host.fonts.mono.name)
            // (customizeAttrs [
              "markdown.preview.fontFamily"
              "chat.fontFamily"
              "notebook.markup.fontFamily"
            ] host.fonts.sans.name);

            jsonFormat = pkgs.formats.json { };

            userDir =
              if pkgs.stdenv.isDarwin then "Library/Application Support/Code/User" else ".config/Code/User";
            extensionPath = ".vscode/extensions";
            extensionDrv = pkgs.writeText "extensions-json" (pkgs.vscode-utils.toExtensionJson extensions);
          in
          {
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
