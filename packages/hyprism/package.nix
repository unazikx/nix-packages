{
  appimageTools,
  fetchurl,
  dotnet-runtime_10,
  icu,
  openssl,
  zlib,
  lib,
}:

appimageTools.wrapType2 rec {
  pname = baseNameOf ./.;
  version = "3.0.3";

  src = fetchurl {
    url = "https://github.com/hyprismteam/HyPrism/releases/download/v${version}/HyPrism-linux-x86_64-${version}.AppImage";
    hash = "sha256-sjcBEY48CB0CH6ETiBDUd3/VEdrQ4BkjRsx1H4ja7QE=";
  };

  extraPkgs = _: [
    dotnet-runtime_10
    icu
    openssl
    zlib
  ];

  description = "Shows battery level on hyprlock screen";
  homepage = "https://gitlab.com/ntgn/helium-flake/-/blob/main/README.md?ref_type=heads#obtaining-extensions";
  license = lib.licenses.wtfpl;
  platforms = [ "x86_64-linux" ];
  mainProgram = "helium-prefetcher";
}
