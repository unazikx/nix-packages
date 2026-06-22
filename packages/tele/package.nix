{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (_old: {
  pname = baseNameOf ./.;
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "sorokin-vladimir";
    repo = "tele";
    tag = "v${_old.version}";
    hash = "sha256-8FHcw1YXEKyP5lE3HyBO7id8KjW/WdrMB3A10LpWG7g=";
  };

  vendorHash = "sha256-KR2hSb0ONHejm/Z9ysu6LWEieylu2LvGpxtiAbXduzc=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Keyboard-first Telegram client for the terminal";
    homepage = "https://github.com/sorokin-vladimir/tele";
    license = lib.licenses.gpl3Only;
    mainProgram = "tele";
  };
})
