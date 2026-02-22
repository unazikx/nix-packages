{
  runCommand,
  lib,
}:

runCommand "build-little-fox" {
  meta = {
    description = "A minimalistic, mouse centered CSS theme for FireFox.";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ azikxz ];
  };
} /* bash */ "cp ${./userChrome.css} $out"
