{
  python312Packages,
  fetchPypi,
  lib,
}:

python312Packages.buildPythonPackage (old: {
  pname = baseNameOf ./.;
  version = "11.1.0";
  pyproject = true;

  src = fetchPypi {
    pname = "HdRezkaApi";
    inherit (old)
      version
      ;
    hash = "sha256-ks8C+kBVI99c8CGyCMGv11ZvslKoSrBkcUXoZnNLnHU=";
  };

  dependencies = [
    python312Packages.requests
    python312Packages.beautifulsoup4
  ];

  build-system = [
    python312Packages.setuptools
  ];

  meta = {
    description = "Unofficial Python library for parsing content from HDRezka";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
    ];
    maintainers = with lib.maintainers; [ azikxz ];
  };
})
