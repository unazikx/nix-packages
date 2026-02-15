{
  perSystem =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      packages.rezka-fzf =
        let
          pyPkgs = pkgs.python3Packages;
        in
        pyPkgs.buildPythonApplication {
          pname = "rezka-fzf";
          version = "git";
          format = "other";

          src = ../rezka_fzf.py;
          dontUnpack = true;

          propagatedBuildInputs = [
            pkgs.mpv
            pkgs.fzf
            config.packages.hdrezka-api
          ];

          installPhase = ''
            install -Dm775 $src $out/bin/rezka-fzf
          '';

          meta = {
            description = "Watch movies/series from rezka in terminal";
            license = lib.licenses.wtfpl;
            platforms = [ "x86_64-linux" ];
            maintainers = with lib.maintainers; [ azikxz ];
            mainProgram = "rezka-fzf";
          };
        };
    };
}
