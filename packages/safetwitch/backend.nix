{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (_old: {
  pname = "safetwitch-backend";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "unazikx";
    repo = "safetwitch-backend";
    tag = "v${_old.version}";
    hash = "sha256-kdmM2hf205uVYAb/pK92pXO1WQMCeSoP5uI511XljM0=";
  };

  vendorHash = "sha256-vXDeXCnxXoHX0kWUaK++lDpYGfls35qorx720xlfbUE=";

  meta = {
    description = "The backend for SafeTwitch";
    homepage = "https://github.com/unazikx/safetwitch-backend";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    # maintainers = with lib.maintainers; [ unazikx ];
    mainProgram = "safetwitch";
  };
})
