{
  python312Packages,
  fetchFromGitHub,
  lib,
}:

python312Packages.buildPythonPackage (_old: {
  pname = baseNameOf ./.;
  version = "0.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hukkin";
    repo = "mdformat-config";
    tag = _old.version;
    hash = "sha256-v6xtU6qZMhUnWFcCJOm9CcmLe6nKxmV9qGDM8o8MPe4=";
  };

  preBuild = ''
    sed -i '/taplo/d' pyproject.toml
  '';

  build-system = [ python312Packages.poetry-core ];

  dependencies = [
    python312Packages.mdformat
    python312Packages.ruamel-yaml
  ];

  pythonImportsCheck = [ "mdformat_config" ];

  meta = {
    description = "Mdformat plugin to beautify configuration and data-serialization formats";
    homepage = "https://github.com/hukkin/mdformat-config";
    changelog = "https://github.com/hukkin/mdformat-config/releases/tag/${_old.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ unazikx ];
  };
})
