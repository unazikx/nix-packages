{
  stdenv,
  lib,
}:

stdenv.mkDerivation {
  pname = baseNameOf ./.;
  version = "local";

  src = ./script.sh;
  dontUnpack = true;

  installPhase = ''
    install -Dm755 $src $out/bin/torque
  '';

  meta = {
    description = "TUI client for Transmission written in bash";
    homepage = "https://github.com/dylanaraps/torque";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "torque";
  };
}
