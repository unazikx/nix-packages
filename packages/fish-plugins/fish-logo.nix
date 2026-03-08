{
  lib,
  fishPlugins,
  fetchFromGitHub,
}:

fishPlugins.buildFishPlugin {
  pname = "fish-logo";
  version = "git";

  src = fetchFromGitHub {
    owner = "laughedelic";
    repo = "fish_logo";
    rev = "dc6a40836de8c24c62ad7c4365aa9f21292c3e6e";
    hash = "sha256-DZXQt0fa5LdbJ4vPZFyJf5FWB46Dbk58adpHqbiUmyY=";
  };

  meta = {
    description = "Fish shell colorful ASCII-art logo";
    homepage = "https://github.com/laughedelic/fish_logo";
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
