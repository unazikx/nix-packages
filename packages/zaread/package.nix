{
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  libreoffice-fresh,
  zathura,
  md2pdf,
  file,
  lib,
}:

stdenv.mkDerivation {
  pname = baseNameOf ./.;
  version = "git";

  src = ./script.sh;
  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/zaread
    wrapProgram $out/bin/zaread \
      --prefix PATH ':' \
        "${
          lib.makeBinPath [
            libreoffice-fresh
            zathura
            md2pdf
            file
          ]
        }"

    runHook postInstall
  '';

  meta = {
    description = "A (very) lightweight MS Office file reader via zathura";
    homepage = "https://github.com/paoloap/zaread";
    license = lib.licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ azikx ];
    mainProgram = "zaread";
  };
}
