{
  stdenv,
  fetchurl,
  php84,
  lib,
}:

stdenv.mkDerivation (_old: {
  pname = baseNameOf ./.;
  version = "0.4.95";

  src = fetchurl {
    url = "https://github.com/lkrms/pretty-php/releases/download/v${_old.version}/pretty-php.phar";
    sha256 = "sha256-4rM0xvNiGrmekOApP3BstKXiUIHsEkadytjHyht7wug=";
  };

  dontUnpack = true;

  buildInputs = [
    php84
  ];

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 $src $out/share/pretty-php.phar
    ln -s $out/share/pretty-php.phar \
      $out/bin/php-formatter
  '';

  meta = {
    description = "Opinionated PHP code formatter";
    homepage = "https://github.com/lkrms/pretty-php";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "php-formatter";
  };
})
