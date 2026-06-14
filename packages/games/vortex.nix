{
  stdenv,
  fetchzip,
  lib,
}:

stdenv.mkDerivation (_old: {
  name = "vortex-server";
  # version where? fckn devs didnt made pinned version

  src = fetchzip {
    url = "https://vortex.storage.clo.ru/vortex-server.zip";
    sha256 = "sha256-naRwLEPOR5qJ8HW3jaj2kw6xvmODMK+vjdx8Schnqvk=";
  };

  installPhase = ''
    mkdir $out
    cp -r * $out
  '';

  meta = {
    description = "Minecraft modpack TerraFirmaGreg (TerraFirmaCraft + GregTech + Create)";
    homepage = "https://github.com/TerraFirmaGreg-Team/Modpack-Modern";
    license = lib.licenses.lgpl3Only;
  };
})
