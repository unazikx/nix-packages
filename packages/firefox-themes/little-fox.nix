{
  runCommand,
  lib,
}:

runCommand "build-little-fox" {
  meta = {
    description = "A minimalistic, mouse centered CSS theme for FireFox.";
    homepage = "https://github.com/biglavis/LittleFox";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
} /* bash */ "cp ${./userChrome.css} $out"
