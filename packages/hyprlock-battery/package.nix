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
    install -Dm755 $src $out/bin/hyprlock-battery
  '';

  meta = {
    description = "Shows battery level on hyprlock screen";
    license = lib.licenses.wtfpl;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [
      {
        name = "Aziz Kurbonov";
        github = "unazikx";
        githubId = 189107707;
        email = "xfalwa@gmail.com";
      }
    ];
    mainProgram = "hyprlock-battery";
  };
}
