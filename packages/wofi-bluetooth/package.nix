{
  stdenv,
  makeWrapper,
  wofi,
  lib,
}:

stdenv.mkDerivation {
  pname = baseNameOf ./.;
  version = "git";

  src = ./script.sh;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 $src $out/bin/wofi-bt
    wrapProgram $out/bin/wofi-bt \
      --prefix PATH ':' \
        "${lib.makeBinPath [ wofi ]}"
  '';

  meta = {
    description = "Control bt via wofi";
    homepage = "https://github.com/unazikx/wofi-bluetooth";
    license = lib.licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ unazikx ];
    mainProgram = "wofi-bt";
  };
}
