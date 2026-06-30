{
  stdenv,
  fetchurl,
  p7zip,
  lib,
}:

stdenv.mkDerivation (_old: {
  pname = "voices-of-the-void";
  version = "090n";

  src = fetchurl {
    # https://archive.votv.dev/games/votv
    url = "https://r2.votv.dev/archive/votv/${_old.version}.7z";
    sha256 = "sha256-3qpCNHhx1PDU5zts1mW3UVfCtjty/7kJawCSx+EV6X8=";
  };

  nativeBuildInputs = [ p7zip ];

  installPhase = ''
    mkdir -p $out/bin
    mv WindowsNoEditor/* $out/bin
  '';

  meta = {
    description = "Voices of the Void (Windows version)";
    homepage = "https://mrdrnose.itch.io/votv";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "VotV.exe";
  };
})
