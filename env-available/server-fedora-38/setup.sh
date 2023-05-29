#!/bin/bash -e

DEPS=(
    htop git vim tmux curl
    python-is-python3 custom-ssh-ident
    sysbench stress-ng lm_sensors
    cmake make gcc clang
    libtool custom-neovim custom-nvchad
)

REMOVE_DEPS=(
    zram-generator
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

PUBLIC_DOTFILES="gitconfig gitignore bash_aliases"
for f in ${PUBLIC_DOTFILES}; do
    rm -rf "/home/$SUDO_USER/.$f"
    ln -s "${script_dir}/../../dotfiles/$f" "/home/$SUDO_USER/.$f"
done

LOCAL_DOTFILES="bashrc"
for f in ${LOCAL_DOTFILES}; do
    rm -rf "/home/$SUDO_USER/.$f"
    ln -s "${script_dir}/$f" "/home/$SUDO_USER/.$f"
done

dnf update

for pkg in "${REMOVE_DEPS[@]}"; do
  dnf remove -y "$pkg"
done

for pkg in "${DEPS[@]}"; do
    # if [ "$pkg" ==  ]; then
    # fi

    if [ "$pkg" == custom-ssh-ident ]; then
        ssh_ident_folder="/home/$SUDO_USER/.local/ssh-ident"
        if [ ! -d "$ssh_ident_folder" ]; then
            git clone git@github.com:ccontavalli/ssh-ident.git "$ssh_ident_folder"
            chown -R "$SUDO_USER:$SUDO_USER" "$ssh_ident_folder"
            cd "$ssh_ident_folder"
            ln -s ssh-ident ssh
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-neovim ]; then
        if ! bin_installed "$script_dir/neovim/build/bin/nvim"; then
            cd "$script_dir"
            git clone https://github.com/neovim/neovim
            chown -R "$SUDO_USER:$SUDO_USER" "$script_dir/neovim"
            cd neovim
            runuser -u "$SUDO_USER" -p -- git checkout v0.7.2
            runuser -u "$SUDO_USER" -p -- make CMAKE_BUILD_TYPE=Release -j8
            make install
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvchad ]; then
        if [ ! -d "/home/$SUDO_USER/.config/nvim" ]; then
            git clone https://github.com/NvChad/NvChad "/home/$SUDO_USER/.config/nvim"
            chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config/nvim"
        fi
        if [ ! -L "/home/$SUDO_USER/.config/nvim/lua/custom" ]; then
          ln -s "${script_dir}/../../nvchad" "/home/$SUDO_USER/.config/nvim/lua/custom"
        fi
        echo "$pkg is installed." && continue
    fi

    if ! dnf_installed "$pkg"; then
        dnf install -y "$pkg"
    fi
    echo "$pkg is installed." && continue
done
