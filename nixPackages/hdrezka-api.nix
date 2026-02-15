{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.hdrezka-api =
        let
          pyPkgs = pkgs.python3Packages;
        in
        pyPkgs.buildPythonPackage rec {
          pname = "HdRezkaApi";
          version = "11.1.0";
          pyproject = true;

          src = pkgs.fetchPypi {
            inherit
              pname
              version
              ;
            hash = "sha256-ks8C+kBVI99c8CGyCMGv11ZvslKoSrBkcUXoZnNLnHU=";
          };

          dependencies = [
            pyPkgs.requests
            pyPkgs.beautifulsoup4
          ];

          build-system = [
            pyPkgs.setuptools
          ];
        };
    };
}
