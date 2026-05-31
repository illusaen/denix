{ den, ... }:
{
  # den.aspects.desktop =
  #   { host, lib, ... }:
  #   {
  #     includes = [
  #       den.aspects.desktop._
  #     ]
  #     ++ lib.optionals (host.class == "nixos") [ den.aspects.theming ];
  #   };
  den.aspects.desktop.includes = [ den.aspects.desktop._ ];
}
