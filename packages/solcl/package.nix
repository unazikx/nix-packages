{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (_old: {
  pname = baseNameOf ./.;
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "Cladamos";
    repo = "solcl";
    rev = "f1ab8c5d95a29d3ded0fb0238116b666adcb6aca";
    hash = "sha256-ziAFessQceIKnvN8TG0h87a0R22WUTDkUGlrevuaguk=";
  };

  vendorHash = "sha256-fYPYFS8qDtU1FkfgHUKqjqPUEtwOd3nUhL5+lWNKAfM=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Solar system visualization tui";
    homepage = "https://github.com/Cladamos/solcl";
    license = lib.licenses.mit;
    mainProgram = "solcl";
  };
})
