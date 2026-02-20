{
  stdenv,
  lib,
}:

stdenv.mkDerivation {
  pname = baseNameOf ./.;
  version = "git";

  src = ./script.sh;
  dontUnpack = true;

  installPhase = ''
    install -Dm755 $src $out/bin/torque
  '';

  meta = {
    description = "TUI client for transmission on bash";
    homepage = "https://github.com/dylanaraps/torque";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ azikx ];
    mainProgram = "torque";
  };
}
