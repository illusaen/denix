{
  wlib,
  pkgs,
  ...
}: {
  imports = [wlib.modules.symlinkScript];

  package = pkgs.stdenvNoCC.mkDerivation {
    pname = "autols-fish";
    version = "unstable-2026-04-11";

    src = pkgs.fetchFromGitHub {
      owner = "kpbaks";
      repo = "autols.fish";
      rev = "master";
      hash = "sha256-5zICkcpKkEX2D/17X5KC64Sm3cCYhkaACkUl7+9VLbg=";
    };

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/fish/vendor_{completions,conf,functions}.d

      cp completions/*.fish  $out/share/fish/vendor_completions.d/
      cp conf.d/*.fish       $out/share/fish/vendor_conf.d/
      cp functions/*.fish    $out/share/fish/vendor_functions.d/

      install -Dm644 ${./scripts}/*.fish -t $out/share/fish/vendor_functions.d/

      runHook postInstall
    '';
  };
}
