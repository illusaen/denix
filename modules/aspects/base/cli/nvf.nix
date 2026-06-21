{inputs, ...}: {
  flake-file.inputs.nvf = {
    url = "github:NotAShelf/nvf";
    inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  den.aspects.base.cli.nvf = {
    nixos.imports = [inputs.nvf.nixosModules.default];
    darwin.imports = [inputs.nvf.darwinModules.default];

    os = {
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
          debugMode = {
            logFile = "/tmp/nvim.log";
          };
          spellcheck = {
            enable = true;
            programmingWordlist.enable = true;
          };
          lsp = {
            enable = true;
            formatOnSave = true;
            inlayHints.enable = true;
            lightbulb.enable = true;
            trouble.enable = true;
            otter-nvim.enable = true;
            nvim-docs-view.enable = true;
            presets.harper.enable = true;
          };
          debugger.nvim-dap = {
            enable = true;
            ui.enable = true;
          };
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
            nix = {
              enable = true;
              lsp.servers = ["nixd"];
            };
            python.enable = true;
            rust = {
              enable = true;
              extensions.crates-nvim.enable = true;
            };
            scss.enable = true;
            sql.enable = true;
            svelte.enable = true;
            toml.enable = true;
            tsx.enable = true;
            typescript.enable = true;
            yaml.enable = true;
          };

          visuals = {
            nvim-web-devicons.enable = true;
            nvim-cursorline.enable = true;
            cinnamon-nvim.enable = true;
            fidget-nvim.enable = true;
            highlight-undo.enable = true;
            blink-indent.enable = true;
            indent-blankline.enable = true;
          };

          autopairs.nvim-autopairs.enable = true;
          autocomplete.blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
          };
          tabline.nvimBufferline.enable = true;

          treesitter = {
            enable = true;
            autotagHtml = true;
            context.enable = true;
          };

          binds.whichKey.enable = true;
          keymaps = [
            {
              key = "<C-p>";
              mode = "n";
              action = ''function() require("snacks").picker.files() end'';
              lua = true;
              desc = "Find files";
            }
          ];
          git = {
            enable = true;
            gitsigns.codeActions.enable = false;
          };
          notify.nvim-notify.enable = true;

          utility = {
            diffview-nvim.enable = true;
            surround.enable = true;
            smart-splits.enable = true;
            undotree.enable = true;
            nvim-biscuits.enable = true;
            grug-far-nvim.enable = true;
            direnv.enable = true;
            snacks-nvim.enable = true;
            snacks-nvim.setupOpts.picker.enabled = true;
            images.img-clip.enable = true;
          };

          terminal.toggleterm = {
            enable = true;
            lazygit.enable = true;
          };

          ui = {
            borders.enable = true;
            noice.enable = true;
            colorizer.enable = true;
            illuminate.enable = true;
            smartcolumn = {
              enable = true;
              setupOpts.custom_colorcolumn = {
                # this is a freeform module, it's `buftype = int;` for configuring column position
                nix = "120";
                typescript = "120";
              };
            };
            fastaction.enable = true;
          };

          assistant = {
            chatgpt.enable = true;
            avante-nvim.enable = true;
          };

          comments.comment-nvim.enable = true;

          options = {
            shiftwidth = 0;
            tabstop = 2;
            expandtab = true;
          };
        };
      };
    };
  };
}
