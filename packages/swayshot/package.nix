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
    description = "Simple menu for list data from rbw";
    homepage = "https://gist.github.com/axax-loll/94c563d81c5e8694de0e27aa588a53aa";
    license = lib.licenses.unlicense;
    platforms = [ "x86_64-linux" ];
    mainProgram = "rbw-fzf";
  };
}
