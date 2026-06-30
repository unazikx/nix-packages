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
  pname = baseNameOf ./.;
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
    description = "Wrapper for portablemc with automatic JVM selection from Nix packages";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "portablemc-jvm";
  };
}
