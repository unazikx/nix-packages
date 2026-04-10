{
  mkWindowsApp,
  fetchurl,
  p7zip,
  wine,
  ouch,
  lib,
}:

let
  gameDir = "$WINEPREFIX/drive_c/Program Files/VotV";
in

mkWindowsApp rec {
  pname = "voices-of-the-void";
  version = "a09j_0001";

  src = fetchurl {
    url = "https://archive.votv.zip/VDMR/archive-mrdrnose-votv/${version}.7z";
    sha256 = "sha256-3qpCNHhx1PDU5zts1mW3UVfCtjty/7kJawCSx+EV6X8=";
  };

  dontUnpack = true;
  nativeBuildInputs = [ p7zip ];

  inherit wine;
  wineArch = "win64";
  enableMonoBootPrompt = false;
  persistRegistry = false;
  persistRuntimeLayer = false;
  fileMapDuringAppInstall = false;

  fileMap = {
    "$HOME/.local/share/VotV" = "drive_c/users/$USER/AppData/Local/VotV";
  };

  winAppInstall =
    # bash
    ''
      winetricks -q corefonts
      winetricks -q fontsmooth=rgb
      winetricks -q vcrun2022 dxvk

      mkdir -p "${gameDir}"
      ${lib.getExe ouch} d ${src} -d "${gameDir}"
    '';

  winAppPreRun =
    # bash
    ''
      mkdir -p "${gameDir}"
    '';

  winAppRun =
    # bash
    ''
      mkdir -p "${gameDir}"
      wine start /unix "$WINEPREFIX/drive_c/votv/${version}/WindowsNoEditor/VotV.exe" "$ARGS"
    '';

  winAppPostRun = toString null;

  installPhase = ''
    runHook preInstall
    ln -s $out/bin/.launcher $out/bin/${pname}
    runHook postInstall
  '';

  meta = {
    description = "Voices of the Voice packaged for NixOS";
    homepage = "https://mrdrnose.itch.io/votv";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [
      {
        name = "Aziz Kurbonov";
        github = "unazikx";
        githubId = 189107707;
        email = "xfalwa@gmail.com";
      }
    ];
    mainProgram = "hasher";
  };
}
