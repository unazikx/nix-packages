{
  fetchPypi,
  python312Packages,
  lib,
}:

python312Packages.buildPythonApplication (_old: {
  pname = "uvicorn";
  version = "0.43.0";
  pyproject = true;

  src = fetchPypi {
    inherit (_old)
      pname
      version
      ;
    hash = "sha256-qxZS0vsjq/Ek82zMOZgoVYiA3vIiw8s9mNJAIVINxug=";
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
    maintainers = with lib.maintainers; [
      {
        name = "Aziz Kurbonov";
        github = "unazikx";
        githubId = 189107707;
        email = "xfalwa@gmail.com";
      }
    ];
  };
})
