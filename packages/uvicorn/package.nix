{
  fetchPypi,
  python312Packages,
  lib,
}:

python312Packages.buildPythonApplication (_old: {
  pname = "uvicorn";
  version = "0.41.0";
  pyproject = true;

  src = fetchPypi {
    inherit (_old)
      pname
      version
      ;
    hash = "sha256-CdEc9wCNozETgk7locZCLYn7wv9HZUDWmjTIf6uLVxo=";
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
    # maintainers = with lib.maintainers; [ unazikx ];
  };
})
