{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.opnix.url = "github:brizzbuzz/opnix";

  den.aspects.base.cli.opnix = {
    nixos = {
      imports = [inputs.opnix.nixosModules.default];

      systemd.services.opnix-secrets = {
        unitConfig = {
          StartLimitIntervalSec = lib.mkForce "5min";
          StartLimitBurst = lib.mkForce 30;
        };

        serviceConfig.RestartSec = lib.mkForce "10s";
      };
    };

    darwin = {
      imports = [inputs.opnix.darwinModules.default];
    };

    os.services.onepassword-secrets = {
      enable = true;
      tokenFile = "/etc/opnix-token";
      secrets = {
        sshPrivateKey = {
          reference = "op://Service/SSH-Key-Nix/private key?ssh-format=openssh";
          path = "/etc/ssh/id_rsa";
          mode = "0644";
        };
        sshPublicKey = {
          reference = "op://Service/SSH-Key-Nix/public key";
          path = "/etc/ssh/id_rsa.pub";
          mode = "0644";
        };
      };
    };

    persist.files = [
      "/etc/opnix-token"
      {
        file = "/etc/ssh/id_rsa";
        mode = "0644";
      }
      "/etc/ssh/id_rsa.pub"
    ];

    provides.to-users.darwin = {user, ...}: {
      users.groups.onepassword-secrets.members = [user.name];
    };
  };
}
