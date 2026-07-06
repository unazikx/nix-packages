{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  lib,
}:

stdenv.mkDerivation (_old: {
  pname = baseNameOf ./.;
  version = "MatriX.142";

  src = fetchurl {
    url = "https://github.com/YouROK/TorrServer/releases/download/${_old.version}/TorrServer-linux-amd64";
    sha256 = "sha256-yJtnHZ9ARepKmbTJsoS7ROrmGjF5jasuSMfm/G/d/UM=";
  };
  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/torrserver
    runHook postInstall
  '';

  meta = {
    description = "Server for streaming torrents";
    homepage = "https://github.com/YouROK/TorrServer";
    license = lib.licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    mainProgram = "torrserver";
  };
})
