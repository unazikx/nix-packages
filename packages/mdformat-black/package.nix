{
  python312Packages,
  fetchFromGitHub,
  lib,
}:

python312Packages.buildPythonPackage (_old: {
  pname = baseNameOf ./.;
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hukkin";
    repo = "mdformat-black";
    tag = _old.version;
    hash = "sha256-HAuge6naa3BOX/xLVUFOdG76iNmk4X5WEuAPIMWgPXw=";
  };

  build-system = [
    python312Packages.flit-core
    python312Packages.poetry-core
  ];

  dependencies = [
    python312Packages.mdformat
    python312Packages.black
  ];

  pythonImportsCheck = [ "mdformat_black" ];

  meta = {
    description = "Mdformat plugin to Blacken Python code blocks";
    homepage = "https://github.com/hukkin/mdformat-black";
    changelog = "https://github.com/hukkin/mdformat-black/releases/tag/${_old.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ unazikx ];
  };
})
