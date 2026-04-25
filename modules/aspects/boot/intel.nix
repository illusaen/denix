{ den, inputs, ... }:
{
  flake-file.inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  den.aspects.intel = den.lib.perHost {
    nixos =
      { config, modulesPath, ... }:
      {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          inputs.nixos-hardware.nixosModules.common-cpu-intel
        ];
        boot.kernelModules = [ "kvm-intel" ];
        hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
        hardware.enableAllFirmware = true;
        hardware.enableRedistributableFirmware = true;
      };
  };
}
