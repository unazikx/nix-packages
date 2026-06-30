{
  stdenv,
  fetchurl,
  lib,
}:

stdenv.mkDerivation (_old: {
  pname = "tiny11";
  version = "202311";

  src = fetchurl {
    name = "${_old.pname}-${_old.version}.iso";
    url = "https://archive.org/download/tiny11-2311/tiny11%202311%20x64.iso";
    # or   https://archive.org/download/tiny-11-NTDEV/tiny11%2023H2%20x64.iso
    # use another hash
    sha256 = "sha256-oCiACpGt3DXYriLc50WbZzMPfWnS8Rxw9TwP3/pbQoA=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    install -Dm755 $src $out/bin/tiny11.iso
  '';

  meta = {
    description = "Tiny11 - lightweight Windows 11 build";
    homepage = "https://archive.org/details/tiny-11-NTDEV";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
})
