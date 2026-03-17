{
  fetchtorrent,
  runCommand,
  lib,
}:

let
  files = fetchtorrent {
    backend = "rqbit";
    url = "magnet:?xt=urn:btih:88F4B99C029443B4032FE05230C31DEF7868914E&tr=http%3A%2F%2Fbt2.t-ru.org%2Fann%3Fmagnet&dn=%5BDL%5D%20Webbed%20%5BP%5D%20%5BRUS%20%2B%20ENG%20%2B%207%5D%20(2021%2C%20Arcade)%20%5BPortable%5D";
    hash = "sha256-hHgN44emyuRH+fVcC3D7SV5FHOph9afMC0Tku+Mfs8k=";
  };
in

runCommand "files-${baseNameOf ./.}"
  {
    meta = {
      description = "Webbed is the story of a happy little spider on an adventure to save her boyfriend from a big mean bowerbird.";
      homepage = "https://rutracker.org/forum/viewtopic.php?t=6107017";
      license = lib.licenses.unfree;
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
  }
  ''
    mkdir -p $out
    cp -r ${files}/* $out
  ''
