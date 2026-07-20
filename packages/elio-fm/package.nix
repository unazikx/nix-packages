{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:

rustPlatform.buildRustPackage (_old: {
  pname = "elio";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    tag = "v${_old.version}";
    hash = "sha256-SrYRn+JZXSy7F3Jfx1u2ht/lL31FG+BtxzuIu4kHeek=";
  };

  cargoHash = "sha256-W7C3e8pRCPoorxQhs1jkpnTKNn3oTEOhI1tG3HZFxpw=";

  doCheck = false;

  meta = {
    description = "Terminal file manager with rich previews, inline images, and trash support";
    homepage = "https://elio-fm.github.io";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "elio";
  };
})
