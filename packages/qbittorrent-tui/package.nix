{
  python312Packages,
  lib,
}:

python312Packages.buildPythonApplication {
  pname = baseNameOf ./.;
  version = "git";

  src = ./script.py;
  dontUnpack = true;

  propagatedBuildInputs = [
    python312Packages.python
    python312Packages.urwid
    python312Packages.requests
  ];

  format = "other";

  installPhase = ''
    install -Dm755 $src $out/bin/qbtui
  '';

  meta = {
    description = "Control qBittorrent via TUI";
    homepage = "https://gist.github.com/azikz/1368b57a9dd8c5af1396d6ff94ac5395";
    license = lib.licenses.wtfpl;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ unazikx ];
    mainProgram = "qbt-tui";
  };
}
