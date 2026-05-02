{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = baseNameOf ./.;
  version = "git";

  src = fetchFromGitHub {
    owner = "tranarchy";
    repo = "dcfetch";
    rev = "b4f6ef292649569a9b0d092393953fbbccdb500a";
    hash = "sha256-jizIqhGTJCcnWmwbjgRAmFihT4SMOo29INe1YgULufg=";
  };

  buildPhase = ''
    $CC src/main.c src/dict_util.c src/os.c src/rpc.c \
        ${
          if stdenv.isLinux then
            "src/audio/linux.c"
          else if stdenv.isDarwin then
            "src/audio/macos.m"
          else
            "src/audio/unsupported.c"
        } \
        -Iinclude -Wall -o dcfetch \
        ${
          if stdenv.isLinux then
            "$(pkg-config --cflags --libs libpulse)"
          else if stdenv.isDarwin then
            "-framework Foundation -F /System/Library/PrivateFrameworks -weak_framework MediaRemote"
          else
            ""
        }
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m775 dcfetch $out/bin
  '';
}
