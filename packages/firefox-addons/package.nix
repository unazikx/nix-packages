{
  pkgs,
  lib,
}:

let
  inherit (pkgs.nur.repos.rycee.firefox-addons)
    buildFirefoxXpiAddon
    ;
in

(import ./output.nix {
  inherit
    buildFirefoxXpiAddon
    lib
    ;
})
// {
  # INFO:
  # not iva (_old: { ... }) cause idk
  "voice-over-translation" = buildFirefoxXpiAddon rec {
    pname = "voice-over-translation";
    version = "1.11.1";
    addonId = "vot-extension@firefox";
    url = "https://github.com/ilyhalight/voice-over-translation/releases/download/${version}/vot-extension-firefox-${version}.xpi";
    sha256 = "sha256-X3ZsVVAXNtuQloRMY0v382zxYT2GE5a9ra0BfpfO5mE=";
    meta = with lib; {
      homepage = "https://github.com/ilyhalight/voice-over-translation";
      description = "A small extension that adds voice-over translation of videos from YaBrowser to other browsers";
      license = licenses.mit;
      mozPermissions = [
        "storage"
        "notifications"
        "tabs"
        "declarativeNetRequestWithHostAccess"
        "<all_urls>"
      ];
      platforms = platforms.all;
    };
  };
}
