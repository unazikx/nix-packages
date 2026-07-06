{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:

rustPlatform.buildRustPackage (_old: {
  pname = "elio";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    tag = "v${_old.version}";
    hash = "sha256-/Y9KtGoqD78QHmUtAooQmmI7ZTOSNY7DdrhHYVFMj5E=";
  };

  cargoHash = "sha256-7BP/LoNBnukD2ThtjhAYN8iv0cA0tNg3+GNAjlN6yIM=";

  doCheck = false;

  meta = {
    description = "Terminal file manager with rich previews, inline images, and trash support";
    homepage = "https://elio-fm.github.io";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "elio";
  };
})
