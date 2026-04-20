{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:

rustPlatform.buildRustPackage {
  pname = "niri-sidebar";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Vigintillionn";
    repo = "niri-sidebar";
    rev = "83603353eceb51a0a1d889b17713000dcb222794";
    hash = "sha256-YDNugm3RQ65tN0jYdD0sO//AWYGJ+P+WP8APu40r2fM=";
  };

  cargoHash = "sha256-13gDpYcG0gB35zu8pzKUuSRvTc10cCjWQkIg42zejpc=";

  meta = {
    description = "A lightweight, external sidebar manager for the Niri window manager";
    homepage = "https://github.com/Vigintillionn/niri-sidebar";
    license = lib.licenses.mit;
    platforms = lib.platforms.x86_64;
    mainProgram = "niri-sidebar";
  };
}
