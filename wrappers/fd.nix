{
  wlib,
  pkgs,
  ...
}: {
  imports = [wlib.modules.default];

  package = pkgs.fd;
  flags = {
    "--hidden" = true;
    "--follow" = true;
    "--exclude" = ".git";
  };
}
