{
  wlib,
  pkgs,
  ...
}:
{
  imports = [ wlib.modules.default ];

  package = pkgs.eza;
  flags = {
    "--icons" = "auto";
    "--git" = true;
  };
}
