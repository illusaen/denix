{ den, inputs, ... }:
{
  flake-file.inputs.opnix.url = "github:brizzbuzz/opnix";

  den.aspects.base.cli.includes = with den.aspects.base.cli; [ opnix ];

  den.aspects.base.cli.opnix = {
    nixos =
      { host, ... }:
      {
        imports = [ inputs.opnix.nixosModules.default ];
        users.users = builtins.mapAttrs (_: _: {
          extraGroups = [
            "onepassword-secrets"
          ];
        }) host.users;
      };

    darwin =
      { host, lib, ... }:
      {
        imports = [ inputs.opnix.darwinModules.default ];
        users.groups.onepassword-secrets.members = lib.attrNames host.users;
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
  };
}
