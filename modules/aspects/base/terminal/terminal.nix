{
  den,
  ...
}:
{
  den.aspects.base.terminal = {
    includes = with den.aspects.base.terminal; [
      ghostty
      foot
      kitty
    ];
  };
}
