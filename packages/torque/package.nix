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
    description = "TUI client for transmission on bash";
    homepage = "https://github.com/dylanaraps/torque";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [
      {
        name = "Aziz Kurbonov";
        github = "unazikx";
        githubId = 189107707;
        email = "xfalwa@gmail.com";
      }
    ];
    mainProgram = "torque";
  };
}
