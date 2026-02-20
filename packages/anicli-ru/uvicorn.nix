{
  fetchPypi,
  python312Packages,
  lib,
}:

python312Packages.buildPythonApplication (old: {
  pname = "uvicorn";
  version = "0.40.0";
  pyproject = true;

  src = fetchPypi {
    inherit (old)
      pname
      version
      ;
    hash = "sha256-g5Z2Z16H5zaUUYtVdP0PJMnZe0a+oW33uMBeoaUQceo=";
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
    maintainers = with lib.maintainers; [ azikx ];
  };
})
