{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  zlib,
  openssl,
  cacert,
  alsa-lib,
  libpulseaudio,
  libglvnd,
  libxext,
  libxrender,
  hicolor-icon-theme,
  glibc,
  libxcursor,
  libxinerama,
  libxi,
  libxrandr,
  libxfixes,
  libxdamage,
  libxcomposite,
  lib,
}:

stdenv.mkDerivation (old: {
  pname = "occt";
  version = "15.0.13";

  src = fetchurl {
    url = "https://www.ocbase.com/download-bin/edition:Personal/os:Linux/version:${old.version}";
    sha256 = "sha256-Ujrhv1on5LZGXd1rYlQGgPczb+4hli4E9lytAZu1Hpc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    zlib
    openssl
    cacert
    alsa-lib
    libpulseaudio
    libglvnd
    libxext
    libxrender
    hicolor-icon-theme
    glibc
    libxcursor
    libxinerama
    libxi
    libxrandr
    libxfixes
    libxdamage
    libxcomposite
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/occt $out/bin $out/share/{applications,licenses/occt}

    install -m755 $src $out/opt/occt/occt

    touch $out/opt/occt/disable_update
    touch $out/opt/occt/use_home_config

    makeWrapper $out/opt/occt/occt $out/bin/occt \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath old.buildInputs}" \
      --set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 1 \
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set SSL_CERT_DIR "${cacert}/etc/ssl/certs" \
      --set LOCALE_ARCHIVE "${glibc}/lib/locale/locale-archive" \
      --prefix XDG_DATA_DIRS : "${hicolor-icon-theme}/share"

    echo "Proprietary OCCT License - Personal Edition" > $out/share/licenses/occt/LICENSE
      
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "occt";
      exec = "occt %U";
      icon = "occt";
      desktopName = "OverClock Checking Tool";
      comment = old.meta.description;
      categories = [
        "System"
        "Utility"
      ];
      startupWMClass = "OCCT";
      terminal = false;
    })
  ];

  meta = {
    description = "OverClock Checking Tool - CPU/GPU stress testing and monitoring";
    homepage = "https://www.ocbase.com";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "x86_64-windows"
    ];
    maintainers = with lib.maintainers; [ unazikx ];
    mainProgram = "occt";
  };
})
