{
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  ffmpeg,
  flac,
  libogg,
  libvorbis,
  lib,
}:

buildGoModule (_old: {
  pname = "cliamp";
  version = "1.37.0";

  src = fetchFromGitHub {
    owner = "bjarneo";
    repo = "cliamp";
    tag = "v${_old.version}";
    hash = "sha256-O1fArslP3U52Ou4qaw3YGQEXWcTFn7MUqIuj1SmQA8I=";
  };

  vendorHash = "sha256-raj7FKKC9xLrbYQR+l4AH3X2RPQKzLvghKK+FvFXryU=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    alsa-lib
    ffmpeg
    flac
    libogg
    libvorbis
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Terminal Winamp - a retro terminal music player inspired by Winamp 2.x";
    homepage = "https://github.com/bjarneo/cliamp";
    license = lib.licenses.mit;
    mainProgram = "cliamp";
  };
})
