{
  fetchPypi,
  python312Packages,
  lib,
}:

python312Packages.buildPythonApplication (_old: {
  pname = baseNameOf ./.;
  version = "0.51.0";
  pyproject = true;

  src = fetchPypi {
    inherit (_old)
      pname
      version
      ;
    hash = "sha256-9vS2m2V8MS9RbdLSaKua5vJUsR5LrFBPN7KrWLJN0LA=";
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
