{
  stdenv,
  makeWrapper,
  wofi,
  lib,
}:

stdenv.mkDerivation {
  pname = baseNameOf ./.;
  version = "local";

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
    maintainers = with lib.maintainers; [
      {
        name = "Aziz Kurbonov";
        github = "unazikx";
        githubId = 189107707;
        email = "xfalwa@gmail.com";
      }
    ];
    mainProgram = "wofi-bt";
  };
}
