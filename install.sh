#!/usr/bin/env bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Determine architecture.
ARCH="$(uname -m)"
case ${ARCH} in
  x86_64)
    BITS="64"
    ;;
  x86_32)
    BITS="32"
    ;;
  *)
    echo "Unknown arch: ${ARCH}"
    exit 1
esac

# Download and extract latest version of the engine.
echo "Retrieving latest version information"
url=$(wget -q -O- https://godotengine.org/download/linux | grep -Eo "https://downloads.tuxfamily.org/godotengine/[0-9.]+/Godot_v[0-9.]+-stable_x11.${BITS}.zip")
file=${url##*/}

if [ ! -f ${BASEDIR}/${file} ]; then
  echo "Retrieving latest version"
  wget ${url}
else
  echo "Latest version found locally"
fi

echo "Extracting"
unzip -o ${BASEDIR}/${file}
exe=${file%*.zip}
chmod a+x ${BASEDIR}/${exe}

# Generate and install desktop file.
echo "Creating desktop menu entry"
tmpdir=$(mktemp -d)
cat <<DESKTOP > ${tmpdir}/godot-engine.desktop
[Desktop Entry]
Icon=${BASEDIR}/godot_logo.svg
Exec=${BASEDIR}/${exe}
Name=Godot
Type=Application
DESKTOP
xdg-desktop-menu install ${tmpdir}/godot-engine.desktop

# Cleanup.
rm -rf ${tmpdir}

echo "Done"
