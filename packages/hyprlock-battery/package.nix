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
    install -Dm755 $src $out/bin/hyprlock-battery
  '';

  meta = {
    description = "Shows battery level on hyprlock screen";
    license = lib.licenses.wtfpl;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ unazikx ];
    mainProgram = "hyprlock-battery";
  };
}
