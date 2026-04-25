{ den, lib, ... }:
{
  den.aspects.desktop = {
    includes = lib.attrValues den.aspects.desktop._;
  };
}
