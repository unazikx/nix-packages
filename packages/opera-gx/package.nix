{
  stdenv,
  fetchurl,
  alsa-lib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  autoPatchelfHook,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  gtk3,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  makeWrapper,
  nss,
  pango,
  qt6,
  wrapGAppsHook3,
  lib,
}:

stdenv.mkDerivation (_old: {
  pname = "opera-gx";
  version = "128.0.5807.97";

  src = fetchurl {
    url = "https://download3.operacdn.com/ftp/pub/opera_gx/${_old.version}/linux/opera-gx-stable_${_old.version}_amd64.deb";
    sha256 = "sha256-xHxVPqgTjYJ6Jkcm4LO1vaKX8kxZgRr2Viy95/n0Klc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    qt6.wrapQtAppsHook
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gtk3
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nss
    pango
    qt6.qtbase
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share $out/lib

    cp -r usr/share/* $out/share
    cp -r usr/lib/* $out/lib

    sed -i "s|opera-gx %U|$out/bin/hayase|" $out/share/applications/*.desktop

    rm $out/lib/x86_64-linux-gnu/opera-gx-stable/libqt5_shim.so

    makeWrapper $out/lib/x86_64-linux-gnu/opera-gx-stable/opera $out/bin/opera-gx \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath _old.buildInputs}"
  '';

  meta = {
    description = "Gaming browser";
    homepage = "https://www.opera.com/gx";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        name = "Aziz Kurbonov";
        github = "unazikx";
        githubId = 189107707;
        email = "xfalwa@gmail.com";
      }
    ];
  };
})
