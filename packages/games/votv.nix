{
  stdenv,
  fetchurl,
  p7zip,
  lib,
}:

stdenv.mkDerivation (_old: {
  pname = "voices-of-the-void";
  version = "a09j_0001";

  src = fetchurl {
    url = "https://archive.votv.zip/VDMR/archive-mrdrnose-votv/${_old.version}.7z";
    sha256 = "sha256-3qpCNHhx1PDU5zts1mW3UVfCtjty/7kJawCSx+EV6X8=";
  };

  nativeBuildInputs = [ p7zip ];

  installPhase = ''
    mkdir -p $out/bin
    mv WindowsNoEditor/* $out/bin
  '';

  meta = {
    description = "Voices of the Void (windows version)";
    homepage = "https://mrdrnose.itch.io/votv";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [
      {
        name = "Aziz Kurbonov";
        github = "unazikx";
        githubId = 189107707;
        email = "xfalwa@gmail.com";
      }
    ];
    mainProgram = "VotV.exe";
  };
})
