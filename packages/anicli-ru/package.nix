{
  python312Packages,
  fetchPypi,
  anicli-api,
  uvicorn,
  lib,
}:

python312Packages.buildPythonApplication (_old: {
  pname = "anicli_ru";
  version = "6.1.1";
  pyproject = true;

  src = fetchPypi {
    inherit (_old)
      pname
      version
      ;
    hash = "sha256-I6As9MU1juEFeiluachOyE8FjA8eybe6jcj7stAGrWc=";
  };

  build-system = [ python312Packages.hatchling ];

  dependencies = [
    python312Packages.jinja2
    python312Packages.prompt-toolkit
    python312Packages.python-multipart
    python312Packages.rich
    python312Packages.segno
    python312Packages.typer
    python312Packages.fastapi

    anicli-api
    uvicorn
  ];

  meta = {
    description = "Watch anime with ru sources via mpv";
    homepage = "https://github.com/vypivshiy/ani-cli-ru";
    license = lib.licenses.gpl3;
    # maintainers = with lib.maintainers; [ unazikx ];
    mainProgram = "anicli-ru";
  };
})
