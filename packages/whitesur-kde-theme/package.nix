{
  stdenvNoCC,
  fetchFromGitHub,
  gitUpdater,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "whitesur-kde-theme";
  version = "master";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "whitesur-kde";
    rev = "1e4d960945572d05a3d96bec5253dd83971239f2";
    hash = "sha256-t0bCb1X6BprttUUEcfVqjLskulbFxwXQwUMBn6p8Ho8=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/Kvantum
    cp -r ./Kvantum/WhiteSur $out/share/Kvantum/WhiteSur
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {};
}
