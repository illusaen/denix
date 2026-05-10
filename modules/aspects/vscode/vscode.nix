{ helpers, ... }:
{
  den.aspects.vscode = {
    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ vscode ];
      };

    persistUser.directories = [
      ".codex"
      ".config/Code/User/globalStorage"
    ];

    hj =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      let
        inherit (helpers) mapListToAttrsWith;

        languageSnippets = {
          nix."Den Aspect" = {
            prefix = [
              "den"
              "aspect"
            ];
            body = [
              "{ den, ...}:"
              "{"
              "\tden.ctx.\${1:host}.includes = [ den.aspects.\${2:(.+)} ];"
              "\tden.aspects.\${2:name} = den.lib.per\${4:Host} {"
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
              name = "chatgpt";
              publisher = "openai";
              version = "26.5415.20818";
              sha256 = "sha256-Sr+qt5jsxjQ43GJarnXPMPMsxiPR7kmfthtbtYCEaHs=";
            })
            (pkgs.vscode-utils.extensionFromVscodeMarketplace {
              name = "kdl";
              publisher = "kdl-org";
              version = "2.1.3";
              sha256 = "sha256-Jssmb5owrgNWlmLFSKCgqMJKp3sPpOrlEUBwzZSSpbM=";
            })
            (pkgs.vscode-utils.extensionFromVscodeMarketplace {
              name = "vscode-shadcn-svelte";
              publisher = "Selemondev";
              version = "0.6.8";
              sha256 = "sha256-u623oSLBK14u30dDQwFl/QtjjV1410OUldsck0gafLo=";
            })
            (pkgs.vscode-utils.extensionFromVscodeMarketplace {
              name = "vs-code-extension";
              publisher = "inlang";
              version = "2.2.0";
              sha256 = "sha256-+BUtdmrPztTx7Hoc/SP4MNOPrUyT1n1DWabuxTUylnw=";
            })
            (pkgs.vscode-utils.extensionFromVscodeMarketplace {
              name = "catppuccin-vsc";
              publisher = "Catppuccin";
              version = "3.19.0";
              sha256 = "sha256-6/NHZkg37b6RyZIP89FMltSii+7sC5UTfHYFgyYyl4A=";
            })
          ]
          ++ lib.singleton (
            pkgs.runCommandLocal "vscode-theme-extension"
              {
                vscodeExtUniqueId = "custom";
                vscodeExtPublisher = "illusaen";
                version = "0.0.0";
              }
              ''
                mkdir -p "$out/share/vscode/extensions/$vscodeExtUniqueId/themes"
                cp ${./theme-extension-package.json} "$out/share/vscode/extensions/$vscodeExtUniqueId/package.json"
                cp ${
                  config.scheme {
                    template = ./vscode-theme.json.mustache;
                    extension = ".json";
                  }
                } "$out/share/vscode/extensions/$vscodeExtUniqueId/themes/custom.json"
              ''
          );
        userSettings = {
          "direnv.restart.automatic" = true;
          "editor.defaultFormatter" = "ibecker.treefmt-vscode";
          "editor.fontWeight" = 500;
          "editor.fontLigatures" = true;
          "editor.formatOnPaste" = true;
          "editor.formatOnSave" = true;
          "editor.lineHeight" = 1.4;
          "editor.minimap.enabled" = false;
          "editor.wordWrap" = "on";
          "editor.wordWrapColumn" = 120;
          "evenBetterToml.formatter.allowedBlankLines" = 1;
          "evenBetterToml.formatter.arrayAutoCollapse" = true;
          "evenBetterToml.formatter.arrayTrailingComma" = true;
          "evenBetterToml.formatter.columnWidth" = 120;
          "explorer.confirmDelete" = false;
          "explorer.confirmDragAndDrop" = false;
          "explorer.decorations.badges" = false;
          "files.associations" = {
            "*.css" = "tailwindcss";
          };
          "files.autoSave" = "afterDelay";
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.enableSmartCommit" = true;
          "nix.enableLanguageServer" = true;
          "nix.formatterPath" = "treefmt";
          "nix.hiddenLanguageServerErrors" = [ "Request textDocument/definition failed." ];
          "nix.serverPath" = "nixd";
          "rust-analyzer.restartServerOnConfigChange" = true;
          "svelte.enable-ts-plugin" = true;
          "svelte.plugin.svelte.format.config.singleQuote" = true;
          "svelte.plugin.svelte.format.config.svelteStrictMode" = true;
          "terminal.integrated.profiles.osx" = {
            fish.path = "fish";
          };
          "terminal.integrated.defaultProfile.osx" = "fish";
          "terminal.integrated.defaultProfile.linux" = "fish";
          "terminal.integrated.sendKeybindingsToShell" = true;
          "treefmt.command" = "$(which treefmt)";
          "js/ts.inlayHints.enumMemberValues.enabled" = true;
          "js/ts.inlayHints.parameterTypes.enabled" = true;
          "js/ts.inlayHints.variableTypes.enabled" = true;
          "js/ts.inlayHints.functionLikeReturnTypes.enabled" = true;
          "js/ts.inlayHints.propertyDeclarationTypes.enabled" = true;
          "js/ts.referencesCodeLens.enabled" = true;
          "js/ts.implementationsCodeLens.enabled" = true;
          "window.zoomLevel" = 1;
          "window.titleBarStyle" = "custom";
          "json.schemaDownload.trustedDomains" = {
            "https://developer.microsoft.com/json-schemas/" = true;
            "https://json-schema.org/" = true;
            "https://json.schemastore.org/" = true;
            "https://raw.githubusercontent.com/devcontainers/spec/" = true;
            "https://raw.githubusercontent.com/microsoft/vscode/" = true;
            "https://schemastore.azurewebsites.net/" = true;
            "https://shadcn-svelte.com" = true;
            "https://www.schemastore.org/" = true;
            "https://inlang.com/schema/" = true;
          };
          "update.mode" = "none";
          "extensions.autoCheckUpdates" = false;
          "workbench.sideBar.location" = "right";
          "workbench.panel.defaultLocation" = "right";
          "workbench.startupEditor" = "none";
          "workbench.iconTheme" = "catppuccin-macchiato";
          "workbench.colorTheme" = "Catppuccin Macchiato";
          "workbench.colorCustomizations" =
            (mapListToAttrsWith [
              "titleBar.activeBackground"
              "titleBar.inactiveBackground"
              "editor.background"
              "editorGutter.background"
              "editorPane.background"
              "editorGroupHeader.tabsBackground"
              "editorOverviewRuler.background"
              "breadcrumb.background"
              "tab.activeBackground"
              "tab.inactiveBackground"
              "tab.selectedBackground"
              "tab.unfocusedActiveBackground"
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
            ] config.scheme.withHashtag.base00)
            // (mapListToAttrsWith [
            ] config.scheme.withHashtag.base03);
        }
        // (mapListToAttrsWith [
          "editor.fontSize"
          "debug.console.fontSize"
          "markdown.preview.fontSize"
          "terminal.integrated.fontSize"
          "chat.editor.fontSize"
        ] (builtins.floor (config.myLib.fonts.sizes.terminal * 1.1)))
        // (mapListToAttrsWith [
          "editor.fontFamily"
          "editor.inlayHints.fontFamily"
          "editor.inlineSuggest.fontFamily"
          "scm.inputFontFamily"
          "debug.console.fontFamily"
          "chat.editor.fontFamily"
        ] "${config.myLib.fonts.mono.name},Maple Mono NF CN")
        // (mapListToAttrsWith [
          "editor.inlayHints.fontFamily"
          "editor.inlineSuggest.fontFamily"
        ] "Monaspace Xenon NF,${config.myLib.fonts.mono.name},Maple Mono NF CN")
        // (mapListToAttrsWith [
          "markdown.preview.fontFamily"
          "chat.fontFamily"
          "notebook.markup.fontFamily"
        ] config.myLib.fonts.sans.name);

        jsonFormat = lib.generators.toJSON { };

        userDir =
          if pkgs.stdenv.isDarwin then "Library/Application Support/Code/User" else ".config/Code/User";
      in
      {
        files = lib.mkMerge (
          lib.flatten [
            {
              ".vscode/argv.json" = {
                generator = jsonFormat;
                value = {
                  password-store = "gnome-libsecret";
                  enable-crash-reporter = true;
                  crash-reporter-id = "d17b2c57-3182-4ec0-a09f-c8abd1812a80";
                }
                // lib.optionalAttrs pkgs.stdenv.isDarwin { password-store = "gnome-libsecret"; };
              };
            }
            {
              "${userDir}/settings.json" = {
                generator = jsonFormat;
                value = userSettings;
              };
            }

            (lib.mkIf (languageSnippets != { }) (
              lib.mapAttrs' (
                language: snippet:
                lib.nameValuePair "${userDir}/snippets/${language}.json" {
                  generator = jsonFormat;
                  value = snippet;
                }
              ) languageSnippets
            ))

            (
              let
                # Adapted from https://discourse.nixos.org/t/vscode-extensions-setup/1801/2
                subDir = "share/vscode/extensions";
                toPaths =
                  ext:
                  map (k: { ".vscode/extensions/${k}".source = "${ext}/${subDir}/${k}"; }) (
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
                    ".vscode/extensions/extensions.json".source = pkgs.writeText "extensions-json" (
                      pkgs.vscode-utils.toExtensionJson extensions
                    );
                  }
                ]
              )
            )
          ]
        );
      };
  };
}
