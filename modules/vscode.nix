{ ... }:
{
  den.aspects.vscode.hm =
    { pkgs, lib, ... }:
    {
      programs.vscode =
        let
          seedbox-ip = "192.168.1.104";
        in
        {
          enable = true;
          profiles.default = {
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
              "editor.fontSize" = lib.mkForce 14;
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
              "window.zoomLevel" = 1;
              # "workbench.colorTheme" = lib.mkForce "Nord";
              "workbench.iconTheme" = "catppuccin-macchiato";
              "workbench.sideBar.location" = "right";
              "workbench.startupEditor" = "none";
              "workbench.panel.defaultLocation" = "right";
              "workbench.colorCustomizations" = {
                "[Stylix]" = {
                  "editor.background" = "#272e33";
                  "editorGutter.background" = "#272e33";
                  "editorPane.background" = "#272e33";
                  "editorGroupHeader.tabsBackground" = "#272e33";
                  "sideBar.background" = "#272e33";
                  "panel.background" = "#272e33";
                  "statusBar.background" = "#272e33";
                  "menu.background" = "#272e33";
                  "commandCenter.background" = "#272e33";
                  "scrollbar.background" = "#272e33";
                  "terminal.background" = "#272e33";
                  "notifications.background" = "#272e33";
                  "activityBar.background" = "#272e33";
                };
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
                catppuccin.catppuccin-vsc-icons
                naumovs.color-highlight
                usernamehw.errorlens
                arcticicestudio.nord-visual-studio-code
              ]
              ++ [
                (pkgs.vscode-utils.extensionFromVscodeMarketplace {
                  name = "treefmt-vscode";
                  publisher = "ibecker";
                  version = "2.4.1";
                  sha256 = "sha256-ZTRrZDXqK9L7E5fr5NLEa/0ZyTnFdItfytbVuh/qr94=";
                })
              ];
          };
        };
    };
}
