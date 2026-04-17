{
  python312Packages,
  makeWrapper,
  portablemc,
  temurin-jre-bin-17,
  temurin-jre-bin-21,
  temurin-jre-bin-25,
  temurin-jre-bin-8,
  lib,

  jreList ? lib.attrValues {
    inherit
      # keep-sorted start
      temurin-jre-bin-17
      temurin-jre-bin-21
      temurin-jre-bin-25
      temurin-jre-bin-8
      # keep-sorted end
      ;
  },
}:

python312Packages.buildPythonApplication {
  pname = "portablemc-wrapper";
  version = "local";

  src = ./script.py;
  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = jreList;

  format = "other";

  installPhase = ''
    install -Dm755 $src $out/bin/portablemc-jvm

    wrapProgram $out/bin/portablemc-jvm \
      --prefix PATH : ${
        lib.makeBinPath (
          [
            (portablemc.override {
              textToSpeechSupport = false;
              jre = temurin-jre-bin-25;
            })
          ]
          ++ jreList
        )
      }
  '';

  meta = with lib; {
    description = "Обёртка над portablemc с автовыбором JVM из Nix-пакетов";
    license = licenses.mit;
    mainProgram = "portablemc-jvm";
  };
}
