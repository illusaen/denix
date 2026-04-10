{ den, ... }:
{
  # user aspect
  den.aspects.wendy = {
    includes = [
      den.provides.primary-user
      (den.provides.tty-autologin "wendy")
    ];

    user.password = "arst";
  };
}
