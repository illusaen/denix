{ den, lib, ... }:
{
  den.aspects.server.includes = lib.attrValues den.aspects.server._;
}
