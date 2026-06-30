{
  fetchPypi,
  python312Packages,
  lib,
}:

python312Packages.buildPythonApplication (_old: {
  pname = baseNameOf ./.;
  version = "0.49.0";
  pyproject = true;

  src = fetchPypi {
    inherit (_old)
      pname
      version
      ;
    hash = "sha256-6/QnGqWA2d6X+TGS1FlRdt9ukfmq6RnKc+T8B98eZqM=";
  };

  build-system = [ python312Packages.hatchling ];

  dependencies = [
    python312Packages.click
    python312Packages.h11
    python312Packages.typing-extensions
  ];

  meta = {
    description = "ASGI web server implementation for Python";
    homepage = "https://github.com/Kludex/uvicorn";
    license = lib.licenses.bsd3ClauseTso;
    platforms = lib.platforms.all;
    mainProgram = "uvicorn";
  };
})
