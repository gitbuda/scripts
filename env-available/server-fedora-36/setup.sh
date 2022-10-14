#!/bin/bash -e

DEPS=(
    htop git vim tmux
)

script_dir="$( cd "$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "$0")")" && pwd)"
# shellcheck disable=SC1090
source "$script_dir/../../util/os_util"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
fi
if [ "$SUDO_USER" == "" ]; then
    echo "Please run as sudo."
fi

PUBLIC_DOTFILES="gitconfig gitignore"
for f in ${PUBLIC_DOTFILES}; do
    rm -rf "/home/$SUDO_USER/.$f"
    ln -s "${script_dir}/../../dotfiles/$f" "/home/$SUDO_USER/.$f"
done

for pkg in "${DEPS[@]}"; do
    # if [ "$pkg" ==  ]; then
    # fi

    if ! dnf_installed "$pkg"; then
        dnf install -y "$pkg"
    fi
    echo "$pkg is installed." && continue
done
