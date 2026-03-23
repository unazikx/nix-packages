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
  version = "1.24.0";

  src = fetchFromGitHub {
    owner = "bjarneo";
    repo = "cliamp";
    tag = "v${_old.version}";
    hash = "sha256-b14rcfn8R18w7QuhOv24G7xvrvo8eUI62G+Ac2fpOhw=";
  };

  vendorHash = "sha256-UMDCpfSGfvJmI+sImaFzgZpLNaLMgEnmGCqERwPokHM=";

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
