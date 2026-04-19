{
  python312Packages,
  fetchFromGitHub,
  lib,
}:

python312Packages.buildPythonApplication (_old: {
  pname = baseNameOf ./.;
  version = "git";

  src = fetchFromGitHub {
    owner = "Frestein";
    repo = "qute-translate-popup";
    rev = "5b9ee2c379ebff84e5b69d5a81dc3c3335d10871";
    hash = "sha256-7mTpCqBYcHlj3+AkgR+dGRDz75inMCZiZ3/NNlRmnc4=";
  };

  format = "other";

  dependencies = [ python312Packages.requests ];

  installPhase = ''
    install -Dm755 $src/qute-translate-popup $out/bin/translator
  '';

  meta = {
    description = "Userscript for selected text translation";
    homepage = "https://github.com/Frestein/qute-translate-popup";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "translator";
  };
})
