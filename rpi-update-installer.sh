#!/usr/bin/env bash
set -euo pipefail

RPI_UPDATE_URL="https://raw.githubusercontent.com/Hexxeh/rpi-update/master/rpi-update"
INSTALL_PATH="/usr/bin/rpi-update"

usage() {
    echo "Usage: $0 {install|uninstall}"
    exit 1
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "Please run as root:"
        echo "  sudo $0 $1"
        exit 1
    fi
}

install_rpi_update() {
    require_root install

    echo "Installing rpi-update..."

    if ! command -v curl >/dev/null 2>&1; then
        echo "curl is required."
        echo "Install it with:"
        echo "  sudo apt-get update && sudo apt-get install -y curl"
        exit 1
    fi

    curl -fL --retry 3 \
        --output "${INSTALL_PATH}" \
        "${RPI_UPDATE_URL}"

    chmod 0755 "${INSTALL_PATH}"

    echo
    echo "rpi-update installed successfully."
    echo "Location: ${INSTALL_PATH}"
    echo
    "${INSTALL_PATH}" --help 2>/dev/null || true
}

uninstall_rpi_update() {
    require_root uninstall

    if [[ -e "${INSTALL_PATH}" ]]; then
        echo "Removing ${INSTALL_PATH}..."
        rm -f "${INSTALL_PATH}"
        echo "rpi-update uninstalled."
    else
        echo "rpi-update is not installed at ${INSTALL_PATH}."
    fi
}

case "${1:-}" in
    install)
        install_rpi_update
        ;;
    uninstall)
        uninstall_rpi_update
        ;;
    *)
        usage
        ;;
esac
