{ pkgs, scheme }:
with pkgs.vscode-extensions;
[
  jnoortheen.nix-ide
  mkhl.direnv
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
++ [
  (pkgs.runCommandLocal "vscode-theme-extension"
    {
      vscodeExtUniqueId = "custom";
      vscodeExtPublisher = "illusaen";
      version = "0.0.0";
    }
    ''
      mkdir -p "$out/share/vscode/extensions/$vscodeExtUniqueId/themes"
      cp ${./theme-extension-package.json} "$out/share/vscode/extensions/$vscodeExtUniqueId/package.json"
      cp ${
        scheme {
          template = ./vscode-theme.json.mustache;
          extension = ".json";
        }
      } "$out/share/vscode/extensions/$vscodeExtUniqueId/themes/custom.json"
    ''
  )
]
