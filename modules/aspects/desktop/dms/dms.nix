{ den, ... }:
{
  den.aspects.desktop._.dms = den.lib.perHost {
    persistUser.directories = [
      ".config/DankMaterialShell"
      ".config/niri/dms"
      ".cache/DankMaterialShell"
      ".local/state/DankMaterialShell"
    ];

    nixos = {
      programs.dms-shell = {
        enable = true;
        enableVPN = false;
      };

      security.pam.u2f.enable = true;
    };
  };
}
