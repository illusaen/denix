{
  inputs,
  lib,
  ...
}: {
  config = {
    flake-file.inputs.base16.url = "github:SenchoPens/base16.nix";

    den.aspects.base.base16.settings = {pkgs, ...}: {
      imports = [inputs.base16.nixosModule];
      config = {
        _module.args.pkgs = pkgs;
        scheme = ./tokyo-night-moon.yaml;
      };

      colorScheme = lib.mkOption {
        type = lib.types.enum [
          "dark"
          "light"
        ];
        default = "dark";
      };
      lib = lib.mkOption {
        type = lib.types.raw;
        internal = true;
        default = {};
      };
    };
  };
}
