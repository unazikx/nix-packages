{
  lib,
  fishPlugins,
  fetchFromGitHub,
}:

fishPlugins.buildFishPlugin {
  pname = "fish-helix";
  version = "git";

  src = fetchFromGitHub {
    owner = "sshilovsky";
    repo = "fish-helix";
    rev = "d2de6d1f2b03bd35869b1427e727f91612485194";
    hash = "sha256-Zc4v4Ek3gQRNImaLj6sbi9KG3onIl2I24IYZdBSkr40=";
  };

  meta = {
    description = "Helix key bindings for fish";
    homepage = "https://github.com/sshilovsky/fish-helix";
    license = lib.licenses.mit;
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
