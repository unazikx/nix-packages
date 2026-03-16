{
  proton-ge-bin,
  fetchzip,
  lib,
}:

(proton-ge-bin.override {
  steamDisplayName = "Proton-UMU";
}).overrideAttrs
  (
    _final: _: {
      pname = "proton-umu";
      version = "9.0-4e";

      src = fetchzip {
        url = "https://github.com/Open-Wine-Components/umu-proton/releases/download/UMU-Proton-${_final.version}/UMU-Proton-${_final.version}.tar.gz";
        sha256 = "sha256-YwrDmdNEeqE4DCnfEgo1bQv0GnMqaP0PcbVyV2JLbEE=";
      };

      meta = {
        description = "Compatibility tool for Steam Play based on Wine and additional components";
        homepage = "https://github.com/Open-Wine-Components/umu-proton";
        license = lib.licenses.bsd3;
        platforms = [ "x86_64-linux" ];
        maintainers = with lib.maintainers; [
          {
            name = "Aziz Kurbonov";
            github = "unazikx";
            githubId = 189107707;
            email = "xfalwa@gmail.com";
          }
        ];
      };
    }
  )
