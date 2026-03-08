{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage (_old: {
  pname = baseNameOf ./.;
  version = "Client-0.0.2";

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
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [
      {
        name = "Aziz Kurbonov";
        github = "unazikx";
        githubId = 189107707;
        email = "xfalwa@gmail.com";
      }
    ];
  };
})
