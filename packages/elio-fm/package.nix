{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:

rustPlatform.buildRustPackage (_old: {
  pname = "elio";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    tag = "v${_old.version}";
    hash = "sha256-r7/LT0wGs8G9UN7H89WBBYGdKhCU6FXJx+UXNWfIZDc=";
  };

  cargoHash = "sha256-x9qeMsNLELZu+23pQZNwNgOxlx7c+aHCIpzagHO/Hbg=";

  doCheck = false;

  meta = {
    description = "Terminal file manager with rich previews, inline images, and trash support";
    homepage = "https://elio-fm.github.io";
    license = lib.licenses.mit;
    mainProgram = "elio";
  };
})
