{
  fetchPypi,
  python312Packages,
  lib,
}:

python312Packages.buildPythonApplication (_old: {
  pname = "anicli_api";
  version = "0.8.11";
  pyproject = true;

  src = fetchPypi {
    inherit (_old)
      pname
      version
      ;
    hash = "sha256-Hu69ymwgsyLZKPZwzmRFU8WqRKWj/tvgXHCnHx9eeVE=";
  };

  build-system = [ python312Packages.hatchling ];

  dependencies = [
    python312Packages.attrs
    python312Packages.httpx
    python312Packages.httpx.optional-dependencies.http2
    python312Packages.hatchling
    python312Packages.parsel
    python312Packages.tqdm
  ];

  meta = {
    description = "Parse anime from RU websites";
    homepage = "https://github.com/vypivshiy/anicli-api";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ unazikx ];
  };
})
