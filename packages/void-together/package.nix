{
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  lib,
}:

buildNpmPackage (_old: {
  pname = baseNameOf ./.;
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "VoidTogether";
    repo = "VoidTogether-Server";
    rev = "f00208957b08d82702c5f4b9b07ee56c87da46bb";
    hash = "sha256-mjzV36f0sORxELKmdfxXSmlX9VCOykobQR37bCylluQ=";
  };

  npmDepsHash = "sha256-0OevmrVW2yk0nMqcFbjvx8xjyXLuuDxBYU2//nDHuI8=";

  npmInstallFlags = "ci";
  dontNpmBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/void-together
    cp -r * $out/share/void-together
  '';

  meta = {
    description = "VOTV server for multiplayer";
    homepage = "https://github.com/VoidTogether/VoidTogether-Server";
    license = lib.licenses.agpl3Only; # it is unfree
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ azikx ];
  };
})
