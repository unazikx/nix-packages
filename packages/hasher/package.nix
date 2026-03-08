{
  python312Packages,
  lib,
}:

python312Packages.buildPythonApplication {
  pname = baseNameOf ./.;
  version = "local";

  src = ./script.py;
  dontUnpack = true;

  propagatedBuildInputs = [ ];

  format = "other";

  installPhase = ''
    install -Dm755 $src $out/bin/hasher
  '';

  meta = {
    description = "Calculate hash for nix (links or local file)";
    homepage = "https://gist.github.com/unazikx/261536eed5cefe385fa1a0b0eed7b2c2";
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
    mainProgram = "hasher";
  };
}
