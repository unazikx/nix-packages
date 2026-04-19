{
  python312Packages,
  fetchFromGitHub,
  lib,
}:

python312Packages.buildPythonApplication (_old: {
  pname = "toml2nix";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "erooke";
    repo = "toml2nix";
    tag = "v${_old.version}";
    hash = "sha256-9v5oyVcfaZ8l+YrPQSKJezIZJ/uF9Mew9hocm3nggVI=";
  };

  pyproject = true;

  build-system = [ python312Packages.setuptools ];

  meta = {
    description = "Convert toml files to nix";
    homepage = "https://github.com/erooke/toml2nix";
    license = lib.licenses.isc;
    platforms = [ "x86_64-linux" ];
    mainProgram = "toml2nix";
  };
})
