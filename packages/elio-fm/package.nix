{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:

rustPlatform.buildRustPackage (_old: {
  pname = "elio";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    tag = "v${_old.version}";
    hash = "sha256-WMgi0yttCq/PJSps8OrVmWxuogc4stJf0ujY3/yc6XQ=";
  };

  cargoHash = "sha256-LpBKJ2hvwkDgAL2ghFPFPPMoY7KNwp4AkDIQ5+BoCr4=";

  doCheck = false;

  meta = {
    description = "Terminal file manager with rich previews, inline images, and trash support";
    homepage = "https://elio-fm.github.io";
    license = lib.licenses.mit;
    mainProgram = "elio";
  };
})
