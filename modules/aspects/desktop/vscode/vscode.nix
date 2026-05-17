{ den, self, ... }:
{
  den.aspects.desktop.includes = with den.aspects.desktop; [ vscode ];

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
        extensions = import ./_extensions.nix {
          inherit pkgs;
          scheme = self.my.scheme;
        };
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
            {
              "${userDir}/settings.json".source = pkgs.replaceVars ./settings.json.template {
                backgroundColor = self.my.scheme.withHashtag.base00;
                fontSize = builtins.floor (self.my.fonts.sizes.terminal * 1.1);
                monoFontName = "${self.my.fonts.mono.name},Maple Mono NF CN";
                serifFontName = "Monaspace Xenon Frozen";
                sansFontName = self.my.fonts.sans.name;
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
              lib.mkMerge (
                (lib.concatMap toPaths extensions)
                ++ [
                  {
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
