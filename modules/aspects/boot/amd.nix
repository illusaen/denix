{ inputs, ... }:
{
  flake-file.inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  den.aspects.amd.nixos =
    { config, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
        inputs.nixos-hardware.nixosModules.common-cpu-amd
      ];
      boot.kernelModules = [ "kvm-amd" ];
      hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
    };
}
