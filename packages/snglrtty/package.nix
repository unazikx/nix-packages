{
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libpulseaudio,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = baseNameOf ./.;
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "the-unknown";
    repo = "snglrtty";
    rev = "dbb6f06c947abd081c256ac5440b2c8ab268a976";
    hash = "sha256-szoBLOx7wCGBrjoQs332QPQJ9ssrzkYCtQ2Ybqizmiw=";
  };

  cargoHash = "sha256-rIv9P0jkjI+tbkQt4G1gacxhgoqaykB3YtYXxKopv/o=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libpulseaudio
  ];

  meta = {
    description = "Terminal audio visualizer";
    homepage = "https://github.com/the-unknown/snglrtty";
    license = lib.licenses.mit;
    platforms = lib.platforms.x86_64;
    mainProgram = "snglrtty";
  };
}
