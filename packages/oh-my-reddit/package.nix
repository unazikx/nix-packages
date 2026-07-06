{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (_old: {
  pname = baseNameOf ./.;
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "renatoworks";
    repo = "oh-my-reddit";
    tag = "v${_old.version}";
    hash = "sha256-lEbA1zE7S5QKe/gOSaOxlAlsosplaiYUU6hYXKXnLk4=";
  };

  vendorHash = "sha256-Wgj7ebykJjrYjUepqNwa9C5VgIcGvVwAUIdZZt/inFc=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Display Minecraft capes and player heads";
    homepage = "https://github.com/dorochadev/capes";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "capes";
  };
})
