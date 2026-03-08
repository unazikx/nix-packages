{
  python312Packages,
  hdrezka-api,
  mpv,
  fzf,
  lib,
}:

python312Packages.buildPythonApplication {
  pname = baseNameOf ./.;
  version = "local";
  format = "other";

  src = ./script.py;
  dontUnpack = true;

  propagatedBuildInputs = [
    hdrezka-api
    mpv
    fzf
  ];

  installPhase = ''
    install -Dm775 $src $out/bin/rezka-fzf
  '';

  meta = {
    description = "Watch movies/series from rezka in terminal";
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
    mainProgram = "rezka-fzf";
  };
}
