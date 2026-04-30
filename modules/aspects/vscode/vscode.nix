{ den, ... }:
{
  den.aspects.vscode = den.lib.perHost {
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
        osConfig,
        helpers,
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
                  osConfig.myLib.theming.colors {
                    template = ./vscode-theme.json.mustache;
                    extension = ".json";
                  }
                } "$out/share/vscode/extensions/$vscodeExtUniqueId/themes/custom.json"
              ''
          );
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
            colorTheme = "Custom";
            iconTheme = "catppuccin-macchiato";
            sideBar.location = "right";
            startupEditor = "none";
            panel.defaultLocation = "right";
          };
          treefmt.command = "$(which treefmt)";
          "#js/ts".inlayHints.enumMemberValues.enabled = true;
          window = {
            zoomLevel = 1;
            titleBarStyle = "custom";
          };
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
          update.mode = "none";
          extensions.autoCheckUpdates = false;
        }
        // (mapListToAttrsWith [
          "editor.fontSize"
          "debug.console.fontSize"
          "markdown.preview.fontSize"
          "terminal.integrated.fontSize"
          "chat.editor.fontSize"
        ] (osConfig.myLib.fonts.sizes.terminal * 1.1))
        // (mapListToAttrsWith [
          "editor.fontFamily"
          "editor.inlayHints.fontFamily"
          "editor.inlineSuggest.fontFamily"
          "scm.inputFontFamily"
          "debug.console.fontFamily"
          "chat.editor.fontFamily"
        ] osConfig.myLib.fonts.mono.name)
        // (mapListToAttrsWith [
          "markdown.preview.fontFamily"
          "chat.fontFamily"
          "notebook.markup.fontFamily"
        ] osConfig.myLib.fonts.sans.name);

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
