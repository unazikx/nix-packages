{
  inputs,
  stdenv,
  lib,
}:

let
  inherit (inputs.rycee-pkgs.lib.${stdenv.hostPlatform.system})
    buildFirefoxXpiAddon
    ;
in

import ./output.nix {
  inherit
    buildFirefoxXpiAddon
    lib
    ;
}
