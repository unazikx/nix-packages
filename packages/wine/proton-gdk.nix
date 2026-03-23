{
  proton-ge-bin,
  fetchzip,
  lib,
}:

(proton-ge-bin.override {
  steamDisplayName = "Proton-GDK";
}).overrideAttrs
  (
    _final: _: {
      pname = "proton-gdk";
      version = "release10-32";

      src = fetchzip {
        url = "https://github.com/Weather-OS/GDK-Proton/releases/download/release${_final.version}/GDK-Proton${_final.version}.tar.gz";
        sha256 = "sha256-x6LuikI5/hdl6+Y0llTYLDJbX+flma1wJSrJYHxyYQ0=";
      };

      meta = {
        description = "WineGDK Protonified";
        homepage = "https://github.com/Weather-OS/GDK-Proton";
        license = lib.licenses.unfree; # og proton-ge is lib.licenses.bsd3
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
