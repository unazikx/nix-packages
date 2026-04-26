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
  version = "3.0.2";

  src = fetchurl {
    url = "https://github.com/hyprismteam/HyPrism/releases/download/v${version}/HyPrism-linux-x86_64-${version}.AppImage";
    hash = "sha256-mTZGwZuugn4U5MDXbcT/pyUHSnCT+KUSAGCxUxXgYpE=";
  };

  extraPkgs = _: [
    dotnet-runtime_10
    icu
    openssl
    zlib
  ];
}
