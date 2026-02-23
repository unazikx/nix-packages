{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage {
  pname = "safetwitch-frontend";
  version = "2.4.5";

  src = fetchFromGitHub {
    owner = "unazikx";
    repo = "safetwitch-frontend";
    rev = "ddee63ebbe8b7b74d8f6ed3869cd7958934746d7";
    hash = "sha256-1Bkj1TNdiARL4K5RHGlXoQUwpOc9E/qq6ADhb3svKjU=";
  };

  npmDepsHash = "sha256-afkspBoLCrcDvC8djvXTBu8EPRrwxBQnvUOlPF4zKGE=";

  installPhase = ''
    runHook preBuild

    mkdir -p $out/share/safetwitch
    cp -r -t $out/share/safetwitch dist/*

    runHook postBuild
  '';

  meta = {
    description = "SafeTwitch is a privacy respecting frontend for twitch.tv";
    homepage = "https://github.com/unazikx/safetwitch-frontend";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ unazikx ];
    mainProgram = "safetwitch";
  };
}
