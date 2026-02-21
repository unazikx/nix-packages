{
  pkgs,
  lib,
}:

let
  inherit (pkgs.nur.repos.rycee.firefox-addons)
    buildFirefoxXpiAddon
    ;
in

import ./output.nix {
  inherit
    buildFirefoxXpiAddon
    lib
    ;
}
