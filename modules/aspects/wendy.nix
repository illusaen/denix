{ den, ... }:
{
  # user aspect
  den.aspects.wendy = {
    includes = [
      den.provides.primary-user
    ];

    user.password = "arst";

    persistUser.directories = [
      "Downloads"
      "Projects"
      "Pictures"
    ];
  };
}
