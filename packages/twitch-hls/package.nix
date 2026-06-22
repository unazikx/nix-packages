{
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  lib,
}:

rustPlatform.buildRustPackage (_old: {
  pname = baseNameOf ./.;
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "2bc4";
    repo = "twitch-hls-client";
    tag = _old.version;
    hash = "sha256-6b0EX7ykeYSUvfT03Ot6JiFk7EETF5b69FhnGZb6prI=";
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
    mainProgram = "twitch-hls-client";
  };
})
