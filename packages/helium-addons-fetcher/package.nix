{
  stdenv,
  lib,
}:

stdenv.mkDerivation (_old: {
  pname = baseNameOf ./.;
  version = "9946ec4be3f81e48e49595bd9307bf544a05cee0";

  src = ./script.sh;
  dontUnpack = true;

  installPhase = ''
    install -Dm755 $src $out/bin/helium-prefetcher
  '';

  meta = {
    description = "Fetch and package Helium browser extensions for Nix";
    homepage = "https://gitlab.com/ntgn/helium-flake";
    license = lib.licenses.wtfpl;
    platforms = [ "x86_64-linux" ];
    mainProgram = "helium-prefetcher";
  };
})
