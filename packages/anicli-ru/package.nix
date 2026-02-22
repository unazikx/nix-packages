{
  callPackage,
  fetchPypi,
  python312Packages,
  lib,
  anicli-api ? callPackage ./anicli-api.nix { },
  uvicorn ? callPackage ./uvicorn.nix { },
}:

python312Packages.buildPythonApplication (_old: {
  pname = "anicli_ru";
  version = "6.0.2";
  pyproject = true;

  src = fetchPypi {
    inherit (_old)
      pname
      version
      ;
    hash = "sha256-mDkXJGL0YeIYP5wKkMG56Tte284nsUEDkOxRCCn3Snc=";
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
    maintainers = with lib.maintainers; [ azikx ];
    mainProgram = "anicli-ru";
  };
})
