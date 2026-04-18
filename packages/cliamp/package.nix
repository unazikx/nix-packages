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
  version = "1.35.1";

  src = fetchFromGitHub {
    owner = "bjarneo";
    repo = "cliamp";
    tag = "v${_old.version}";
    hash = "sha256-OchWogdRK2xL8iTf6CDH773xKsQFkUQKMD92hHlrNHg=";
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
    maintainers = with lib.maintainers; [
      {
        name = "Aziz Kurbonov";
        github = "unazikx";
        githubId = 189107707;
        email = "xfalwa@gmail.com";
      }
    ];
    mainProgram = "cliamp";
  };
})
