#!/usr/bin/env bash
set -euo pipefail

CCR_DIR="$(dirname "$(realpath "$0")")"

EMULATOR_DIR="${CCR_DIR}/.emulator"
mkdir -p "${EMULATOR_DIR}"

EMULATOR_COMPUTER_DIR="${EMULATOR_DIR}/computer"
mkdir -p "${EMULATOR_COMPUTER_DIR}"

function linkIntoComputer() {
    COMPUTER_ID="${1}"
    SOURCE_DIR="${2}"

    dest_dir="${EMULATOR_COMPUTER_DIR}/${COMPUTER_ID}/$(basename "${SOURCE_DIR}")"
    mkdir -p "$(dirname "${dest_dir}")"
    if [[ ! -d "${dest_dir}" ]]; then
        echo "Linking $(basename "${SOURCE_DIR}") dir to computer ${COMPUTER_ID}"

        ln -s "${SOURCE_DIR}" "${dest_dir}"
    fi
}

for i in $(seq 0 10);
do
    linkIntoComputer "${i}" "${CCR_DIR}/ccr_remote"
done

cat <<EOF > "${EMULATOR_DIR}/ccemux.json"
{
  "httpEnable": true,
  "httpWhitelist": [
    "*", "\$private"
  ],
  "httpBlacklist": [],
  "http": {
    "websocketEnabled": true
  }
}
EOF

nix run "${CCR_DIR}#ccemux-launcher" -- --data-dir "${EMULATOR_DIR}"