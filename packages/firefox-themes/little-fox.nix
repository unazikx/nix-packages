{
  runCommand,
  lib,
}:

runCommand "build-little-fox" {
  meta = {
    description = "Minimalistic, mouse-centered CSS theme for Firefox";
    homepage = "https://github.com/biglavis/LittleFox";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
} /* bash */ "cp ${./userChrome.css} $out"
