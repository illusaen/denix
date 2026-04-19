# Provides shell utilities under `den.sh` for building OS configurations using
# github:nix-community/nh instead of nixos-rebuild, etc
{
  lib,
  den,
  inputs,
  ...
}:
{
  options.den.sh = lib.mkOption {
    description = "Non-flake Den shell environment";
    default = den.lib.nh.denShell {
      fromFlake = false;
      outPrefix = [ "flake" ];
    } (import inputs.nixpkgs { });
  };

  config = {
    den.ctx.host.includes = [ den.aspects.nh ];
    den.aspects.nh = {
      os = {
        programs.fish.shellAbbrs = {
          nd = "nh clean all";
          buildmodi = "nixos-rebuild switch --flake .#modi --target-host wendy@192.168.1.104 --use-remote-sudo";
        };
      };

      nixos.programs.fish.shellAbbrs.bb = "nh os switch .";
      darwin.programs.fish.shellAbbrs.bb = "nh darwin switch .";
    };
  };
}
