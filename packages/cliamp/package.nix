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
  version = "1.34.1";

  src = fetchFromGitHub {
    owner = "bjarneo";
    repo = "cliamp";
    tag = "v${_old.version}";
    hash = "sha256-nhgdM0C+QgvTdXLrbo0DNJPVhqaumQgNBd3bmiwDk8M=";
  };

  vendorHash = "sha256-sS0tjZoZ81Jwn/KJnJD01fTA4z0HxEYYM89Ta398MP0=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    alsa-lib
    ffmpeg
    flac
    libogg
    libvorbis
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
