{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (_old: {
  pname = baseNameOf ./.;
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "sorokin-vladimir";
    repo = "tele";
    tag = "v${_old.version}";
    hash = "sha256-ZBym6XcfzLPccavtrT1i0wxuM8C3EhNJTlQHsdNc78Y=";
  };

  vendorHash = "sha256-tZkIsry/MyILMb2USafVmzBfTbqeNQNZ/QtRryGCHgQ=";

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
