{
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  lib,
}:

rustPlatform.buildRustPackage (_old: {
  pname = baseNameOf ./.;
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "2bc4";
    repo = "twitch-hls-client";
    tag = _old.version;
    hash = "sha256-AoefKtAiM8Xi1DoPDH2E623QSC668qrQLOLpdtFxuAs=";
  };

  cargoLock.lockFile = "${_old.src}/Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  postInstall = ''
    wrapProgram $out/bin/twitch-hls-client
  '';

  meta = {
    description = "A minimal command line client for watching/recording Twitch streams";
    homepage = "https://github.com/2bc4/twitch-hls-client";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ unazikx ];
    mainProgram = "twitch-hls-client";
  };
})
