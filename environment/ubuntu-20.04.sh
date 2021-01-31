#!/bin/bash -e

script_dir="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
# shellcheck disable=SC1090
source "$script_dir/../util/os_util"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
fi

DEPS=(
    htop tmux vim tree
)

for pkg in "${DEPS[@]}"; do
    if ! deb_installed "$pkg"; then
        apt install -y "$pkg"
    fi
    echo "$pkg is installed." && continue
done
