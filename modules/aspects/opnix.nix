{ den, inputs, ... }:
{
  flake-file.inputs.opnix.url = "github:brizzbuzz/opnix";

  den.ctx.host.includes = [ den.aspects.opnix ];
  den.aspects.opnix = den.lib.perHost {
    nixos = {
      imports = [ inputs.opnix.nixosModules.default ];
    };
    darwin = {
      imports = [ inputs.opnix.darwinModules.default ];
    };

    os = {
      services.onepassword-secrets = {
        enable = true;
        tokenFile = "/etc/opnix-token";
        secrets = {
          sshPrivateKey = {
            reference = "op://Service/SSH-Key-Nix/private key?ssh-format=openssh";
            path = "/etc/ssh/id_rsa";
            mode = "0600";
          };
          sshPublicKey = {
            reference = "op://Service/SSH-Key-Nix/public key";
            path = "/etc/ssh/id_rsa.pub";
            mode = "0600";
          };
        };
      };
    };
  };
}
