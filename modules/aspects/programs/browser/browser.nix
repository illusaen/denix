{ den, ... }:
{
  den.aspects.programs.browser.includes = with den.aspects.programs.browser; [
    firefox
    chrome
  ];
}
