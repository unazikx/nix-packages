{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (_old: {
  pname = baseNameOf ./.;
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "sorokin-vladimir";
    repo = "tele";
    tag = "v${_old.version}";
    hash = "sha256-92W9TRxpUMQj2COCTos9FajALoSaluPBE7m5CD/dM4U=";
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
