{
  appimageTools,
  fetchurl,
  dotnet-runtime_10,
  icu,
  openssl,
  zlib,
}:

appimageTools.wrapType2 rec {
  pname = "hyprism";
  version = "3.0.1";

  src = fetchurl {
    url = "https://github.com/hyprismteam/HyPrism/releases/download/v${version}/HyPrism-linux-x86_64-${version}.AppImage";
    hash = "sha256-vb93cI9ABNJqrhe09JB0oTz5dCe9cPfPj/U3Ps/Ud+s=";
  };

  extraPkgs = _: [
    dotnet-runtime_10
    icu
    openssl
    zlib
  ];
}
