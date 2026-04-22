{ den, ... }:
{
  den.aspects.desktop.includes = [ den.aspects.dms ];
  den.aspects.dms = den.lib.perHost {
    persistUser.directories = [
      ".config/DankMaterialShell"
      ".config/niri/dms"
      ".cache/DankMaterialShell"
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
