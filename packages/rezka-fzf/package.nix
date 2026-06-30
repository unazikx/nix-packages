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

  dependencies = [
    python312Packages.aiohttp
    python312Packages.pyyaml
  ];

  installPhase = ''
    install -Dm775 $src $out/bin/rezka-fzf
  '';

  meta = {
    description = "Watch movies/series from HDRezka in terminal via fzf";
    license = lib.licenses.wtfpl;
    platforms = [ "x86_64-linux" ];
    mainProgram = "rezka-fzf";
  };
}
