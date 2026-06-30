{
  stdenv,
  fetchItchIo,
  unzip,
  autoPatchelfHook,
  lib,
}:

stdenv.mkDerivation {
  pname = "mindustry";
  version = "158.1";

  src = fetchItchIo {
    # INFO:
    # how to fetch?
    # Dev Tools -> Console -> Paste this
    #
    # [...document.querySelectorAll("[data-upload_id]")]
    #   .map(x => ({
    #     name: x.textContent.trim(),
    #     upload: x.dataset.upload_id
    #   }))
    #
    # 2: { name: 'Download', upload: '...' }
    #
    # we need upload
    #
    # then change hash to lib.fakeHash and build
    # u will get hash then paste
    name = "Mindustry.zip";
    hash = "sha256-dmEDlmI2kGafvB9agnntCz5HZuHLIvWisAIH+Jwil+U=";
    gameUrl = "https://anuke.itch.io/mindustry";
    upload = "1615336";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack

    unzip $src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/mindustry}
    cp -r * $out/share/mindustry
    ln -s \
      $out/share/mindustry/Mindustry \
      $out/bin/mindustry

    runHook postInstall
  '';

  meta = {
    description = "Build factories and defense towers";
    homepage = "https://anuke.itch.io/mindustry";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "mindustry";
  };
}
