{
  writeShellApplication,
  file,
  imagemagick,
  zip,
  colors ? { },
  outputDir ? toString null,
  backgroundImage ? toString null,
}:

writeShellApplication {
  name = "walogram";

  runtimeInputs = [
    file
    imagemagick
    zip
  ];

  bashOptions = [ "pipefail" ];

  text =
    # sh
    ''
      tempdir="$(mktemp -d)"
      cachedir="${outputDir}"
      themename="stylix.tdesktop-theme"
      walmode="solid"
      walname="background.jpg"
      blur="true"

      rm "$cachedir/$themename" -f
      mkdir -p "$cachedir"
      echo "${import ./theme.nix colors}" > "$tempdir/colors.tdesktop-theme"
      gentheme() {
        if command -v zip >/dev/null 2>&1; then
          if [ "$walmode" = "solid" ]; then
            magick -size 256x256 "gradient:${colors.base01}-${colors.base00}" "$tempdir/$walname"
          else
            case "$(file -b --mime-type "${backgroundImage}")" in
            image/*) convert ''${blur:+-blur 0x32} -resize 1920x1080 "${backgroundImage}" "$tempdir/$walname" ;;
            *) echo "not an image: ${backgroundImage}" ;;
            esac
          fi
          zip -jq -FS "$cachedir/$themename" "$tempdir"/*
        else
          msg "'zip' not found. theme generated without background image"
          cp -f "$tempdir/colors.tdesktop-theme" "$cachedir/$themename"
        fi
      }

      gentheme
    '';
}
