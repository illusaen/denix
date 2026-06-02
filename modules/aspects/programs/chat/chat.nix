{ den, ... }:
{
  den.aspects.programs.chat.includes = with den.aspects.programs.chat; [
    den.aspects.programs.vesktop
    element
    telegram
  ];
}
