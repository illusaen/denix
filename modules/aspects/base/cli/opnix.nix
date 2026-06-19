{ inputs, ... }:
{
  flake-file.inputs.opnix.url = "github:brizzbuzz/opnix";

  den.aspects.base.cli.opnix = {
    nixos = {
      imports = [ inputs.opnix.nixosModules.default ];
    };

    darwin = {
      imports = [ inputs.opnix.darwinModules.default ];
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

    persist.files = [ "/etc/opnix-token" ];

    provides.to-users.darwin =
      { user, ... }:
      {
        users.groups.onepassword-secrets.members = [ user.name ];
      };
  };
}
