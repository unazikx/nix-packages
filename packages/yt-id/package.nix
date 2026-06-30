{
  stdenv,
  makeWrapper,
  curl,
  libxml2,
  lib,
}:

stdenv.mkDerivation {
  pname = baseNameOf ./.;
  version = "local";

  src = ./script.sh;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 $src $out/bin/ytid
    wrapProgram $out/bin/ytid \
      --prefix PATH : ${
        lib.makeBinPath [
          curl
          libxml2
        ]
      }
  '';

  meta = {
    description = "Extract YouTube channel ID from URL";
    homepage = "https://github.com/avanssion/youtube-channel-id-finder";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "ytid";
  };
}
