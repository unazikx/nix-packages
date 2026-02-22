{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  lib,
}:

stdenv.mkDerivation (_old: {
  pname = baseNameOf ./.;
  version = "137";

  src = fetchurl {
    url = "https://github.com/YouROK/TorrServer/releases/download/MatriX.${_old.version}/TorrServer-linux-amd64";
    sha256 = "sha256-oUDxonG1oIgK2p0uzrUQOx8G6nEwCJ2ldNRaBo+7z3o=";
  };
  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/torrserver
    runHook postInstall
  '';

  meta = {
    description = "Server for live watch torrets";
    homepage = "https://github.com/YouROK/TorrServer";
    license = lib.licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ unazikx ];
    mainProgram = "torrserver";
  };
})
