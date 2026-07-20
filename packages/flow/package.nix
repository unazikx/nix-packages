{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (_old: {
  pname = baseNameOf ./.;
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "programmersd21";
    repo = "flow";
    tag = "v0.1.1";
    hash = "sha256-XUFwjydJEDisRRxQALmGsMIzCvrsfCPKuyZoUzr0kOI=";
  };

  vendorHash = "sha256-dAO2TcCs82rpweqM257MpKe6yxB/zBkCy5fbqLr3JQQ=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "See your network breathe";
    homepage = "https://github.com/programmersd21/flow#install";
    license = lib.licenses.mit;
    platforms = lib.flatten [
      lib.platforms.windows
      lib.platforms.linux
      lib.platforms.darwin
    ];
    mainProgram = "cliamp";
  };
})
