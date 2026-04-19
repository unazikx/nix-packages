{
  python312Packages,
  fetchurl,
  lib,
}:

python312Packages.buildPythonApplication (_old: {
  pname = baseNameOf ./.;
  version = "git";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/Frestein/qute-translate-popup/5b9ee2c379ebff84e5b69d5a81dc3c3335d10871/qute-translate-popup";
    sha256 = "sha256-VWIxZ+48qKYkRnOKxG4hTjHfrNHQC/KCfiHr0LgRZSw=";
  };

  dontUnpack = true;

  format = "other";

  installPhase = ''
    install -Dm755 $src $out/bin/translator
  '';

  meta = {
    description = "Userscript for selected text translation";
    homepage = "https://github.com/Frestein/qute-translate-popup";
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
    mainProgram = "translator";
  };
})
