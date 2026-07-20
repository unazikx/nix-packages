{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (_old: {
  pname = baseNameOf ./.;
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "sorokin-vladimir";
    repo = "tele";
    tag = "v${_old.version}";
    hash = "sha256-jr8jOWjE+TAlAJMOnsrC22G7taOPmTrMtdL3BavaMpg=";
  };

  vendorHash = "sha256-ECtTlX7pw4xywgZJNBXKjzkAFP5BgqcG+6Nk5xz9olY=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Keyboard-first Telegram client for the terminal";
    homepage = "https://github.com/sorokin-vladimir/tele";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "tele";
  };
})
