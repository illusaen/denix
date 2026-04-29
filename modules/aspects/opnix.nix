{ den, inputs, ... }:
{
  flake-file.inputs.opnix.url = "github:brizzbuzz/opnix";

  den.ctx.host.includes = [ den.aspects.opnix._.enable ];
  den.ctx.user.includes = [ den.aspects.opnix._.opnix-user ];

  den.aspects.opnix = {
    _.enable = den.lib.perHost {
      nixos.imports = [ inputs.opnix.nixosModules.default ];
      darwin.imports = [ inputs.opnix.darwinModules.default ];

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
    };

    _.opnix-user = den.lib.perUser (
      { user, ... }:
      {
        nixos.users.users.${user.name}.extraGroups = [ "onepassword-secrets" ];
        darwin.users.groups.onepassword-secrets.members = [ user.name ];
      }
    );
  };
}
