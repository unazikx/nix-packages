{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule {
  pname = "safetwitch-backend";
  version = "git";

  src = fetchFromGitHub {
    owner = "unazikx";
    repo = "safetwitch-backend";
    rev = "91dda1ceb50822cc9b5306f6c1a92f7e8aaf747b";
    hash = "sha256-kdmM2hf205uVYAb/pK92pXO1WQMCeSoP5uI511XljM0=";
  };

  vendorHash = "sha256-vXDeXCnxXoHX0kWUaK++lDpYGfls35qorx720xlfbUE=";

  meta = {
    description = "The backend for SafeTwitch";
    homepage = "https://github.com/unazikx/safetwitch-backend";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ unazikx ];
    mainProgram = "safetwitch";
  };
}
