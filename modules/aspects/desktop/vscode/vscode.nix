{
  den.aspects.desktop.vscode = {
    os =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ vscode ];
      };

    provides.to-users.persistUser.directories = [
      ".codex"
      ".config/Code/User/globalStorage"
    ];

    provides.to-users.hjem =
      {
        pkgs,
        lib,
        osConfig,
        ...
      }:
      let
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
            catppuccin.catppuccin-vsc-icons
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
                  osConfig.scheme {
                    template = ./vscode-theme.json.mustache;
                    extension = ".json";
                  }
                } "$out/share/vscode/extensions/$vscodeExtUniqueId/themes/custom.json"
              ''
          );
        jsonFormat = lib.generators.toJSON { };

        userDir = if pkgs.stdenv.isDarwin then "Library/Application Support/Code/User" else ".config/Code/User";
      in
      {
        files = lib.mkMerge (
          lib.flatten [
            {
              ".vscode/argv.json" = {
                generator = jsonFormat;
                value = {
                  enable-crash-reporter = true;
                  crash-reporter-id = "d17b2c57-3182-4ec0-a09f-c8abd1812a80";
                }
                // lib.optionalAttrs pkgs.stdenv.isLinux { password-store = "gnome-libsecret"; };
              };
            }
            (
              let
                inherit (osConfig.my) fonts;
              in
              {
                "${userDir}/settings.json".source = pkgs.replaceVars ./settings.json.template {
                  backgroundColor = osConfig.scheme.withHashtag.base00;
                  fontSize = builtins.floor (fonts.sizes.terminal * 1.1);
                  monoFontName = "${fonts.mono.name},Maple Mono NF CN";
                  serifFontName = "Monaspace Xenon Frozen";
                  sansFontName = fonts.sans.name;
                };
              }
            )

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
