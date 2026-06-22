{inputs, ...}: {
  flake-file.inputs = {
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    agentic-nvim = {
      url = "github:carlos-algms/agentic.nvim/main";
      flake = false;
    };
  };
  den.aspects.base.cli.nvf = {
    nixos.imports = [inputs.nvf.nixosModules.default];
    darwin.imports = [inputs.nvf.darwinModules.default];

    os = {
      fleet,
      lib,
      pkgs,
      ...
    }: let
      scheme = fleet.my.base16.scheme.withHashtag;
      base16-colors = {
        inherit
          (scheme)
          base00
          base01
          base02
          base03
          base04
          base05
          base06
          base07
          base09
          base0F
          ;
        base08 = scheme.base12;
        base0A = scheme.base13;
        base0B = scheme.base14;
        base0C = scheme.base15;
        base0D = scheme.base16;
        base0E = scheme.base17;
      };
      nvfPins = inputs.nvf.inputs.mnw.lib.npinsToPluginsAttrs pkgs (inputs.nvf + "/npins/sources.json");
      dirtytalkSpell =
        pkgs.runCommandLocal "vim-dirtytalk-programming-spell" {
          nativeBuildInputs = [pkgs.neovim-unwrapped];
        } ''
          set -eu

          mkdir -p "$out/spell"
          cat ${nvfPins."vim-dirtytalk"}/wordlists/*.words > programming.words
          nvim --headless --clean --cmd "mkspell! $out/spell/programming programming.words" -Es -n
        '';
      agentic = pkgs.vimUtils.buildVimPlugin {
        pname = "agentic.nvim";
        version = "master";
        src = inputs.agentic-nvim.outPath;
      };
    in {
      nix.settings = {
        substituters = [
          "https://nvf.cachix.org"
        ];
        trusted-public-keys = [
          "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
        ];
      };

      environment.systemPackages = with pkgs; [codex-acp];

      programs.nvf = {
        enable = true;
        settings.vim = {
          theme = {
            enable = true;
            transparent = true;
            name = "base16";
            inherit base16-colors;
          };
          highlight = lib.pipe ["Normal" "NormalNC" "SignColumn" "FoldColumn" "LineNr" "EndOfBuffer"] [
            (map (k: {
              name = k;
              value = {bg = "NONE";};
            }))
            builtins.listToAttrs
          ];
          options = {
            shiftwidth = 0;
            tabstop = 2;
            softtabstop = 2;
            expandtab = true;
          };
          keymaps = [
            {
              key = "<C-p>";
              mode = "n";
              action = ''function() require("snacks").picker.files() end'';
              lua = true;
              desc = "Find files";
            }
          ];
          lazy.plugins = {
            "agentic.nvim" = {
              package = agentic;
              setupModule = "agentic";
              setupOpts = {provider = "codex-acp";};
              keys = [
                {
                  key = "<C-\\>";
                  mode = ["n" "v" "i"];
                  action = ''function() require("agentic").toggle() end'';
                  lua = true;
                  desc = "Toggle Agentic Chat";
                }
                {
                  key = "<C-'>";
                  mode = ["n" "v"];
                  action = ''function() require("agentic").add_selection_or_file_to_context() end'';
                  lua = true;
                  desc = "Add file or selection to Agentic to Context";
                }
                {
                  key = "<C-,>";
                  mode = ["n" "v" "i"];
                  action = ''function() require("agentic").new_session() end'';
                  lua = true;
                  desc = "New Agentic Session";
                }
              ];
            };
          };
          viAlias = true;
          vimAlias = true;
          preventJunkFiles = true;
          debugMode.enable = false;

          additionalRuntimePaths = [dirtytalkSpell agentic];

          spellcheck = {
            enable = true;
            programmingWordlist.enable = true;
          };

          debugger.nvim-dap = {
            enable = true;
            ui.enable = true;
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
          languages = {
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
            nvim-cursorline = {
              enable = true;
              setupOpts.line_timeout = 0;
            };
            cinnamon-nvim.enable = true;
            fidget-nvim.enable = true;
            indent-blankline.enable = true;
          };

          statusline.lualine.enable = true;
          dashboard.alpha.enable = true;
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

          git = {
            enable = true;
            gitsigns.enable = true;
            gitsigns.codeActions.enable = false;
          };
          notify.nvim-notify = {
            enable = true;
            setupOpts.background_colour = base16-colors.base00;
          };

          utility = {
            diffview-nvim.enable = true;
            surround.enable = true;
            grug-far-nvim.enable = true;
            direnv.enable = true;
            snacks-nvim.enable = true;
            snacks-nvim.setupOpts.picker.enabled = true;
            motion = {
              hop.enable = true;
              leap.enable = true;
              precognition.enable = true;
            };
          };

          comments.comment-nvim.enable = true;
          notes.todo-comments.enable = true;

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
                nix = "120";
                typescript = "120";
              };
            };
            fastaction.enable = true;
            breadcrumbs = {
              enable = true;
              navbuddy.enable = true;
            };
          };
        };
      };
    };
  };
}
