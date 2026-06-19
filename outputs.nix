# flake-file reads this verbatim when regenerating flake.nix.
# Use import-tree here because there is no modules/default.nix entrypoint.
inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
