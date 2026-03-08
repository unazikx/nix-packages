{
  runCommand,
  lib,
}:

runCommand "build-little-fox" {
  meta = {
    description = "A minimalistic, mouse centered CSS theme for FireFox.";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [
      {
        name = "Aziz Kurbonov";
        github = "unazikx";
        githubId = 189107707;
        email = "xfalwa@gmail.com";
      }
    ];
  };
} /* bash */ "cp ${./userChrome.css} $out"
