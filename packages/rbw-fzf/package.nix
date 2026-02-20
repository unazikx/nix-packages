{
  stdenv,
  makeWrapper,
  fzf,
  rbw,
  jq,
  lib,
}:

stdenv.mkDerivation {
  pname = baseNameOf ./.;
  version = "git";

  src = ./script.sh;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 $src $out/bin/rbw-fzf
    wrapProgram $out/bin/rbw-fzf \
      --prefix PATH ':' \
        "${
          lib.makeBinPath [
            fzf
            rbw
            jq
          ]
        }"
  '';

  meta = {
    description = "Simple menu for list data from rbw";
    homepage = "https://gist.github.com/axax-loll/94c563d81c5e8694de0e27aa588a53aa";
    license = lib.licenses.unlicense;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ unazikx ];
    mainProgram = "rbw-fzf";
  };
}
