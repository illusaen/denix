# Secrets

This note compares the local repository with Sini's `nix-config` secret model.
It focuses on agenix, agenix-rekey, preservation compatibility, and whether the
existing opnix integration should be removed.

## How Sini Uses Agenix

Sini uses agenix as the declarative secret transport for host, user, and service
configuration. The core pieces are:

- `modules/den/secrets-config.nix` defines `den.secretsConfig.masterIdentities`.
  This is the canonical list of age public keys that can decrypt/rekey fleet
  secrets. In Sini, it points at `.secrets/pub/master.pub` plus clone/master
  backup keys.
- `modules/den/batteries/agenix.nix` adds the flake inputs:
  `ryantm/agenix`, `sini/agenix-rekey`, and `sini/agenix-rekey-to-sops`.
- The agenix battery imports the agenix and agenix-rekey modules for each
  host class. For NixOS and Darwin it imports the system module; for
  home-manager it adds the agenix home-manager modules through shared modules.
- Host rekey configuration is derived from den scope data:
  `secretsConfig.masterIdentities`, `host.public_key`, `host.secretPath`, and
  the host class.
- User rekey configuration is emitted at user scope. Sini creates a per-user
  age identity secret named `user-identity-${user.name}` and then uses that
  secret as the user's home-manager agenix identity path.
- Service modules declare secrets through an `age-secrets` quirk. A collector
  merges those quirk outputs into the host's final `age.secrets` config.

The important pipeline shape is:

```text
den.secretsConfig.masterIdentities
  -> host/user scope context
  -> agenix host and user aspects
  -> age.rekey.{hostPubkey,generatedSecretsDir,localStorageDir}
  -> age-secrets quirk declarations from services
  -> collector merges into age.secrets
  -> services consume config.age.secrets.<name>.path
```

Sini also uses agenix as part of the user account pipeline. In
`core/users/users.nix`, a user can point at a declarative password file. That
file becomes an `age.secrets."user-password-${user.name}"` entry, and the NixOS
user is configured with `hashedPasswordFile`. This avoids plaintext passwords
in `modules/data/users/*.nix`.

## Preservation Compatibility

Sini's battery checks for its impermanence aspect and prefixes the host SSH key
identity path with `/persist` when needed:

```nix
age.identityPaths = [
  "${persistPrefix}/etc/ssh/ssh_host_ed25519_key"
];
```

This repo uses preservation instead of impermanence. The same design still
applies, but the prefix should come from `host.preservation.persistMount`.
For hosts where `host.preservation.enable = true`, the identity path should be:

```nix
"${host.preservation.persistMount}/etc/ssh/ssh_host_ed25519_key"
```

For non-preserved hosts, it should remain:

```nix
"/etc/ssh/ssh_host_ed25519_key"
```

The host SSH key must be preserved before agenix is relied on for stable
decryption. This repo already preserves SSH host key files through the
preservation aspect, so agenix can fit the existing state model without adding
impermanence.

## How Agenix Should Be Set Up Here

The local repo already has schema placeholders that mention agenix, including
environment wireless secret paths and certificate issuer secret paths. It does
not yet have the actual agenix battery.

A preservation-compatible setup should add these pieces:

1. Add `den.secretsConfig`.
   Define `den.secretsConfig.masterIdentities` as a list of age public key
   paths under `.secrets/pub`. Keep this as the single fleet-wide source of
   rekey recipients.

2. Add agenix inputs.
   Add `agenix`, `agenix-rekey`, and optionally `agenix-rekey-to-sops` as flake
   inputs. The SOPS bridge is useful if Kubernetes or external SOPS output is
   later needed, but it is not required for normal host secrets.

3. Add a host agenix aspect.
   Import `inputs.agenix.nixosModules.default` or the matching Darwin module.
   Configure:

   ```nix
   age.identityPaths = [
     (if host.preservation.enable
      then "${host.preservation.persistMount}/etc/ssh/ssh_host_ed25519_key"
      else "/etc/ssh/ssh_host_ed25519_key")
   ];

   age.rekey = {
     inherit (secretsConfig) masterIdentities;
     storageMode = "local";
     hostPubkey = builtins.readFile host.public_key;
     generatedSecretsDir = host.secretPath + "/generated";
     localStorageDir = host.secretPath + "/rekeyed";
   };
   ```

4. Add a user agenix aspect.
   For each resolved user, generate a per-user identity secret and pass the
   resulting identity path into home-manager agenix. This lets user-level
   modules declare age secrets without depending directly on the host SSH key.

5. Add the `age-secrets` quirk and collector.
   Service modules should expose secret declarations through an `age-secrets`
   quirk. A collector aspect should merge those declarations into the final
   host or Darwin `age.secrets` attrset.

6. Migrate plaintext account passwords.
   The current `wendy` user module contains a plaintext password. The agenix
   migration path should replace that with an encrypted hashed password file:

   ```nix
   age.secrets."user-password-wendy" = {
     rekeyFile = rootPath + "/.secrets/users/wendy/password-hash.age";
     owner = "root";
     group = "root";
     mode = "0400";
   };

   users.users.wendy.hashedPasswordFile =
     config.age.secrets."user-password-wendy".path;
   ```

   Store a password hash in the age secret, not the plaintext password.

## Should Opnix Be Removed?

Not immediately.

Sini uses agenix as infrastructure secret plumbing: secrets needed at
activation, boot, and service startup are declared in Nix and materialized as
files under `config.age.secrets`. That is the right model for host passwords,
service environment files, ACME DNS API tokens, wireless keys, and other
system-managed secrets.

This repo's opnix integration is different. It pulls selected secrets from
1Password and also wires shell/user workflows around the 1Password service
account token. That is useful for interactive workstation workflows and for
secrets that intentionally live in 1Password.

Recommended split:

- Use agenix for declarative system secrets, boot-time secrets, service
  environment files, host/user identities, and account password hashes.
- Keep opnix for 1Password-backed workstation conveniences and interactive
  user secrets.
- Remove opnix only after every consumer of `/etc/opnix-token`,
  `services.onepassword-secrets`, and the shell `OP_SERVICE_ACCOUNT_TOKEN`
  workflow has been migrated or intentionally dropped.

In short: agenix should become the primary NixOS/Darwin secret deployment
mechanism, but opnix should not be removed just because agenix is added. Remove
opnix only if the repo no longer needs 1Password runtime integration.
