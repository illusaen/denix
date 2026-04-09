{ den, inputs, ... }:
{
  flake-file.inputs.opnix.url = "github:brizzbuzz/opnix";

  den.ctx.user.includes = [ den.aspects.opnix ];
  den.aspects.opnix = den.lib.perUser {
    homeManager = {
      imports = [ inputs.opnix.homeManagerModules.default ];
      programs = {
        onepassword-secrets = {
          enable = true;
          tokenFile = "/etc/opnix-token";

          secrets = {
            sshPrivateKey = {
              reference = "op://Service/SSH-Key-Nix/private key?ssh-format=openssh";
              path = ".ssh/id_rsa";
              mode = "0600";
            };
            sshPublicKey = {
              reference = "op://Service/SSH-Key-Nix/public key";
              path = ".ssh/id_rsa.pub";
              mode = "0600";
            };
          };
        };
      };
    };
  };
}
