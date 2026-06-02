{ den, ... }:
{
  den.schema.user.includes = [ den.aspects.user-assertions ];
  den.aspects.user-assertions = {
    nixos =
      { config, user, ... }:
      {
        assertions = [
          {
            assertion =
              let
                inherit (config.users.users.${user.name}) password hashedPassword;
              in
              !(password == null && hashedPassword == null);
            message = "nixos users must set either a password or hashedPassword";
          }
        ];
      };
  };
}
