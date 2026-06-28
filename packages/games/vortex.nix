{
  stdenv,
  fetchzip,
  lib,
}:

stdenv.mkDerivation (_old: {
  pname = "vortex-server";
  version = "1.1.1b";

  src = fetchzip {
    url = "https://vortex.storage.clo.ru/download/v${_old.version}/vortex-${_old.version}-server.zip";
    sha256 = "sha256-naRwLEPOR5qJ8HW3jaj2kw6xvmODMK+vjdx8Schnqvk=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir $out
    cp -r * $out
  '';

  meta = {
    description = "Custom story telling Minecraft modpack";
    homepage = "https://vrtx.su";
    license = lib.licenses.unfree;
  };
})
