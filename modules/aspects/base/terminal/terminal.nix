{
  den,
  ...
}:
{
  den.aspects.base.includes = with den.aspects.base; [ terminal ];

  den.aspects.base.terminal = {
    includes = [ den.aspects.base.terminal._ ];
  };
}
