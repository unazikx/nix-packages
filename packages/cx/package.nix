{
  buildGoModule,
  lib,
}:

buildGoModule {
  pname = "cx";
  version = "local";

  src = ./.;

  vendorHash = null;

  meta = {
    description = "Simple CLI currency converter using Frankfurter API";
    license = lib.licenses.mit;
    mainProgram = "cx";
  };
}
