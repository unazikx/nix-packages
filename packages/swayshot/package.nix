{
  stdenv,
  makeWrapper,
  grim,
  slurp,
  jq,
  wl-clipboard,
  lib,
}:

stdenv.mkDerivation {
  pname = baseNameOf ./.;
  version = "local";

  src = ./script.sh;
  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    install -Dm755 $src $out/bin/swayshot
    wrapProgram $out/bin/swayshot \
      --prefix PATH : ${
        lib.makeBinPath [
          grim
          slurp
          jq
          wl-clipboard
        ]
      }
  '';

  meta = {
    description = "Screenshot tool for Sway with preview and clipboard support";
    license = lib.licenses.unlicense;
    platforms = [ "x86_64-linux" ];
    mainProgram = "swayshot";
  };
}
