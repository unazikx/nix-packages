{
  python312Packages,
  lib,
}:

python312Packages.buildPythonApplication (_old: {
  pname = baseNameOf ./.;
  version = "local";
  format = "other";

  src = ./script.py;
  dontUnpack = true;

  installPhase = ''
    install -Dm775 $src $out/bin/firefox-fetch-addons
  '';

  meta = {
    description = "Watch movies/series from rezka in terminal";
    license = lib.licenses.wtfpl;
    platforms = [ "x86_64-linux" ];
    mainProgram = "rezka-fzf";
  };
})
