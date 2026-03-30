{
  python312Packages,
  fetchPypi,
  lib,
}:

python312Packages.buildPythonPackage (_old: {
  pname = baseNameOf ./.;
  version = "11.2.2";
  pyproject = true;

  src = fetchPypi {
    pname = "hdrezkaapi";
    inherit (_old)
      version
      ;
    hash = "sha256-EW0mr486nc2rm/o22iuCPWmWq/2AcdPlVmha7MUaHj0=";
  };

  dependencies = [
    python312Packages.requests
    python312Packages.beautifulsoup4
  ];

  build-system = [
    python312Packages.setuptools
  ];

  meta = {
    description = "Unofficial Python library for parsing content from HDRezka";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
    ];
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
