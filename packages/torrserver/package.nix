{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  lib,
}:

stdenv.mkDerivation (_old: {
  pname = baseNameOf ./.;
  version = "MatriX.141.4";

  src = fetchurl {
    url = "https://github.com/YouROK/TorrServer/releases/download/${_old.version}/TorrServer-linux-amd64";
    sha256 = "sha256-ba5ULQVtUd29gAs5pSTL9esOvYBvcxBxgh+2V9TVm9k=";
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
    mainProgram = "torrserver";
  };
})
