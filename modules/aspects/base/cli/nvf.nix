{ inputs, ... }: {
  flake-file.inputs.nvf = {
    url = "github:NotAShelf/nvf";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.base.cli.nvf = {
    os = {
      imports = [ inputs.nvf.nixosModules.default ];

      nix.settings = {
        substituters = [
          "https://nvf.cachix.org"
        ];
        trusted-public-keys = [
          "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
        ];
      };

      programs.nvf = {
        enable = true;
        settings.vim = {
          binds.whichKey.enable = true;
          comments.comment-nvim.enable = true;
          syntaxHighlighting = true;
          autopairs.nvim-autopairs.enable = true;
          autocomplete.blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
          };
          formatter.conform-nvim.enable = true;
          git.enable = true;
          languages = {
            enableDAP = true;
            enableExtraDiagnostics = true; # via nvim-lint
            enableFormat = true;
            enableTreesitter = true;
            bash.enable = true;
            css.enable = true;
            fish.enable = true;
            html.enable = true;
            jq.enable = true;
            json.enable = true;
            lua.enable = true;
            markdown.enable = true;
            nix.enable = true;
            python.enable = true;
            rust.enable = true;
            scss.enable = true;
            sql.enable = true;
            svelte.enable = true;
            toml.enable = true;
            tsx.enable = true;
            typescript.enable = true;
            yaml.enable = true;
          };
          lsp = {
            enable = true;
            formatOnSave = true;
            inlayHints.enable = true;
          };
          options = {
            shiftwidth = 0;
            tabstop = 2;
          };
          runner.run-nvim.enable = true;
          tabline.nvimBufferline.enable = true;
          treesitter = {
            enable = true;
            autotagHtml = true;
          };
          utility = {
            direnv.enable = true;
            snacks-nvim.enable = true;
            snacks-nvim.setupOpts.picker.enabled = true;
          };
          visuals.rainbow-delimiters.enable = true;
        };
      };
    };
  };
}
