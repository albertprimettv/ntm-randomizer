#!/bin/bash

# Version History
# ===============
# 2026-11-15
# - Move default `turfmast.zip` location to `/media/fat/ntm-randomizer`
#
# 2026-11-14
# - Initial release

required_vars=("TOOLS_DIR" "OUTPUT_DIR")

# Set defaults for tools dir and output paths (if SAVE_NEO=1)
TOOLS_DIR="/media/fat/ntm-randomizer"
OUTPUT_DIR="/media/fat/games/NEOGEO"
TURFMAST_DIR="/media/fat/ntm-randomizer"

TMP=/tmp/ntm-randomizer
TMP_ZIP=${TMP}/turfmastrand.zip

# source INI file if it exists
[[ -f "ntm-randomizer.ini" ]] && source ntm-randomizer.ini

echo "Checking for required variables"
for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "Error: Required variable '$var' is not set or is empty." >&2
    exit 1
  else
    echo "${var} = [${!var}]"
  fi
done

if [ ! -d "${OUTPUT_DIR}" ]; then
  echo "[${OUTPUT_DIR}] does not exist"
  echo "Create this directory or update TOOLS_DIR in ntm-randomizer.ini and try again."
  exit 1
fi

echo
echo "Checking for required tools and turfmast.zip"

required_tools=("turfmastrand" "lithogen")
for tool in "${required_tools[@]}"; do
    if [[ -f "${TOOLS_DIR}/${tool}" ]]; then
        echo "[${tool}] found"
    else
        echo "[${tool}] not found"
        echo "Make sure [${tool}] exists in [${TOOLS_DIR}] and try again."
        exit 1
    fi
done

if [[ -f "${TURFMAST_DIR}/turfmast.zip" ]]; then
    echo "[${TURFMAST_DIR}/turfmast.zip] found"
else
    echo "[turfmast.zip] not found"
    echo "Make sure an unmodified, merged MAME [turfmast.zip] exists in [${TURFMAST_DIR}] and try again."
    exit 1
fi

if unzip -v "${TURFMAST_DIR}/turfmast.zip" | grep -q -i "28c83048"; then
    echo "[turfmast.zip] is not modified"
else
    echo "Modified [turfmast.zip] found"
    echo "Use an unmodified merged, MAME [turfmast.zip] and try again."
    exit 1
fi

echo
echo "Copying [${TURFMAST_DIR}/turfmast.zip] to [${TMP_ZIP}]"
mkdir -p ${TMP}
cp "${TURFMAST_DIR}/turfmast.zip" ${TMP_ZIP}

echo "Extracting [${TMP_ZIP}]..."
unzip -j -o ${TMP_ZIP} 200-p1.p1 -d ${TMP}

echo
echo "Running randomizer..."
# randomize pin locations if RAND_PINS=1
RAND_ARGS="--holes"
if [ "${RAND_PINS:-0}" -eq 1 ]; then
    RAND_ARGS="--holes --pins"
fi
OUTPUT=$("${TOOLS_DIR}/turfmastrand" ${RAND_ARGS} --p1 ${TMP}/200-p1.p1 --out ${TMP}/200-p1.p1)
echo ${OUTPUT}

echo
echo "Updating with randomized 200-p1.p1..."
zip -v -j ${TMP_ZIP} ${TMP}/200-p1.p1

# append .neo with timestamp if OVERWRITE_NEO=0
if [ "${OVERWRITE_NEO:-0}" -eq 1 ]; then
    NEOFILE="${OUTPUT_DIR}/turfmastrand.neo"
else
    TS=$(date "+%Y%m%d-%H%M%S")
    NEOFILE="${OUTPUT_DIR}/turfmastrand-${TS}.neo"
fi

# SAVE_NEO takes precedence to keep SD card write cycles low
# overwrite filepath to ${TMP}/turfmastrand.neo if SAVE_NEO=0
if [ "${SAVE_NEO:-0}" -eq 0 ]; then
    NEOFILE="${TMP}/turfmastrand.neo"
fi

echo
echo "Building [${NEOFILE}]"
SEED=$(echo "${OUTPUT}" | awk '/^Seed:/ {print $2}')
"${TOOLS_DIR}/lithogen" ${TMP_ZIP} --set turfmast -o "${NEOFILE}" --name "Neo Turf Masters Random-${SEED}"


MGL_OUT=${TMP}/ntm-randomizer.mgl
echo
echo "Writing [${MGL_OUT}]..."

# escape XML special characters (&, <, >, ", ') in case OUTPUT_DIR has any
xml_escape() {
    local s="$1"
    s="${s//&/&amp;}"
    s="${s//</&lt;}"
    s="${s//>/&gt;}"
    s="${s//\"/&quot;}"
    s="${s//\'/&apos;}"
    printf '%s' "$s"
}

SAFE_ROM_PATH="$(xml_escape "${NEOFILE}")"

MGL_OUT=${TMP}/ntm-randomizer.mgl
cat << EOF > "${MGL_OUT}"
<mistergamedescription><rbf>_Console/NeoGeo</rbf><file delay="1" type="f" index="1" path="${SAFE_ROM_PATH}"/></mistergamedescription>
EOF

# cleanup
rm ${TMP}/200-p1.p1 ${TMP_ZIP}

if [ "${AUTOLAUNCH:-1}" -eq 1 ]; then
    echo "load_core ${MGL_OUT}" > /dev/MiSTer_cmd
fi
