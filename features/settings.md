# Settings Resolution

This repo now has two related settings layers:

1. **Typed settings declarations** on aspects.
   These define which keys are valid under `host.settings`.

2. **Resolved settings graph** in `fleet.settings`.
   This evaluates environment, host, and user setting values through the
   scope-engine graph.

The important split is:

- `den.aspects.<path>.settings` declares a schema.
- `den.environments.<env>.settings`, `den.hosts.<system>.<host>.settings`, and
  `den.users.registry.<user>.system.settings` declare values.
- `fleet.settings` answers "what value is visible from this environment, host,
  or resolved user?"

## Settings Declaration Shape

An aspect may declare typed settings with a `settings` attrset:

```nix
{ lib, den, ... }: {
  den.aspects.services.example = {
    settings = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the example feature.";
      };

      logLevel = lib.mkOption {
        type = lib.types.enum [ "debug" "info" "warn" "error" ];
        default = "info";
        description = "Example service log level.";
      };
    };

    nixos = { host, ... }: {
      services.example = {
        enable = host.settings.services.example.enable;
        logLevel = host.settings.services.example.logLevel;
      };
    };
  };
}
```

Because the host schema mirrors the aspect tree, this declaration creates:

```text
host.settings.services.example.enable
host.settings.services.example.logLevel
```

The settings scanner only treats `settings` as a den settings declaration when
it is module-shaped or contains `mkOption` values. This avoids confusing normal
NixOS application fields like `services.foo.settings` for den feature settings.

## Value Locations

Settings values can be placed at three levels.

Environment defaults:

```nix
{
  den.environments.dev.settings.services.example = {
    enable = true;
    logLevel = "warn";
  };
}
```

Host overrides:

```nix
{
  den.hosts.x86_64-linux.odin.settings.services.example = {
    logLevel = "debug";
  };
}
```

User overrides:

```nix
{
  den.users.registry.wendy.system.settings.services.example = {
    logLevel = "info";
  };
}
```

## Scope Graph

`modules/den/scope-engine/settings.nix` builds a graph with these node IDs:

```text
root
env:<environment>
host:<host>
user:<host>:<user>
```

For the current repo, examples are:

```text
env:dev
host:odin
user:odin:wendy
```

Parent edges are:

```text
env:dev -> root
host:odin -> env:dev
user:odin:wendy -> host:odin
```

User nodes are created only for users that resolve onto a host through the same
group/access logic used by the fleet policy.

Environment import edges are also created from delegation settings:

```text
den.environments.<env>.delegation.metricsTo
den.environments.<env>.delegation.authTo
den.environments.<env>.delegation.logsTo
```

For example, if `dev.delegation.metricsTo = "prod"`, then `env:dev` imports
`env:prod` for settings resolution.

## Precedence

`resolvedSettings` merges values in this order:

```text
local > imported > parent
```

That means:

1. A user value overrides everything visible from the host.
2. A host value overrides environment values.
3. An environment value overrides imported/delegated environments and root.
4. Imported environment values override parent/root values.

With this input:

```nix
{
  den.environments.prod.settings.services.example.logLevel = "error";

  den.environments.dev = {
    delegation.metricsTo = "prod";
    settings.services.example.enable = true;
  };

  den.hosts.x86_64-linux.odin.settings.services.example.logLevel = "debug";

  den.users.registry.wendy.system.settings.services.example.logLevel = "info";
}
```

The effective values would be:

```text
env:prod
  services.example.logLevel = "error"

env:dev
  services.example.enable = true
  services.example.logLevel = "error"  # imported from prod

host:odin
  services.example.enable = true       # inherited from dev
  services.example.logLevel = "debug"  # local host override

user:odin:wendy
  services.example.enable = true       # inherited through host/dev
  services.example.logLevel = "info"   # local user override
```

## Reading Settings

Use `fleet.settings.get` to query the graph.

Get every resolved setting visible to a host:

```nix
config.fleet.settings.get "host:odin" "resolvedSettings"
```

Get every resolved setting visible to a user on a host:

```nix
config.fleet.settings.get "user:odin:wendy" "resolvedSettings"
```

Get one key by demand-driven lookup:

```nix
config.fleet.settings.get "host:odin" "setting" "services"
```

Inspect where visible keys came from:

```nix
config.fleet.settings.get "user:odin:wendy" "settingSources"
```

Find keys that shadow a parent/imported value:

```nix
config.fleet.settings.get "host:odin" "overriddenKeys"
```

## Example Consumer

Most host-level aspects should continue reading typed local settings through
the entity argument:

```nix
{ den, lib, ... }: {
  den.aspects.services.example = {
    settings = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      logLevel = lib.mkOption {
        type = lib.types.str;
        default = "info";
      };
    };

    nixos = { host, ... }: {
      services.example = {
        enable = host.settings.services.example.enable;
        logLevel = host.settings.services.example.logLevel;
      };
    };
  };
}
```

Use `fleet.settings` when the consumer needs scope-aware lookup, provenance, or
user-specific settings:

```nix
{ config, host, user, ... }:
let
  settings =
    config.fleet.settings.get
      "user:${host.name}:${user.userName}"
      "resolvedSettings";
in
{
  hjem.users.${user.userName}.files.".config/example/config".text = ''
    logLevel=${settings.services.example.logLevel or "info"}
  '';
}
```

## Practical Rule

Use `host.settings.<aspect-path>` for normal host aspect configuration. Use
`fleet.settings.get ...` when you need to answer questions across scopes:

- "What does this user inherit from their host and environment?"
- "Was this value local or inherited?"
- "Which settings did this host override?"
- "What did this environment import from its delegated target?"

