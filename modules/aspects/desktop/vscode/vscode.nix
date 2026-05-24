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
        extensions = import ./_extensions.nix { inherit pkgs; };
        extensionJsonFile =
          name: text:
          pkgs.writeTextFile {
            inherit text;
            name = "extensions-json-${name}";
            destination = "/share/vscode/extensions/extensions.json";
          };

        profiles = { inherit (extensions) web rust; };
        userDir = if pkgs.stdenv.isDarwin then "Library/Application Support/Code/User" else ".config/Code/User";

        generatedFiles = lib.flatten [
          {
            ".vscode/argv.json" = {
              generator = lib.generators.toJSON { };
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
              monoFontName = "${self.my.fonts.mono},Maple Mono NF CN";
              serifFontName = "Monaspace Xenon Frozen";
              sansFontName = self.my.fonts.sans;
            };
          }

          (lib.mapAttrs' (
            n: v:
            lib.nameValuePair "${userDir}/profiles/${n}/extensions.json" {
              source = "${extensionJsonFile n (pkgs.vscode-utils.toExtensionJson v)}/share/vscode/extensions/extensions.json";
            }
          ) profiles)

          {
            ".vscode/extensions" = {
              source =
                let
                  combinedExtensionsDrv = pkgs.buildEnv {
                    name = "vscode-extensions";
                    paths =
                      (lib.pipe extensions [
                        (lib.collect builtins.isList)
                        lib.flatten
                      ])
                      ++ [
                        (extensionJsonFile "default" (pkgs.vscode-utils.toExtensionJson extensions.default))
                      ];
                  };
                in
                "${combinedExtensionsDrv}/share/vscode/extensions";
            };
          }
        ];
      in
      {
        files = lib.mkMerge generatedFiles;
      };
  };
}
