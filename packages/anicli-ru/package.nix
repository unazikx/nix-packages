{
  python312Packages,
  fetchPypi,
  anicli-api,
  uvicorn,
  lib,
}:

python312Packages.buildPythonApplication (_old: {
  pname = "anicli_ru";
  version = "6.1.2";
  pyproject = true;

  src = fetchPypi {
    inherit (_old)
      pname
      version
      ;
    hash = "sha256-CFpMsQkpvL5H5EBl2VA0pNYrNXqFFierqUn096569eI=";
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
    maintainers = with lib.maintainers; [
      {
        name = "Aziz Kurbonov";
        github = "unazikx";
        githubId = 189107707;
        email = "xfalwa@gmail.com";
      }
    ];
    mainProgram = "anicli-ru";
  };
})
