#!/bin/bash -e

# NOTE: Terminal colors and fonts have to be configured on the Windows side.
#       https://www.tenforums.com/tutorials/179097-how-change-font-size-windows-terminal-profile-windows-10-a.html

DEPS=(
    htop tmux vim tree curl git libssl-dev unzip fontconfig
    python3-virtualenv python3-dev
    custom-ssh-ident
    python-is-python3 # REQUIRED_BY: ssh-ident
    calibre
    clang clang-format gdb
    custom-rust
    custom-nvim
    custom-nvchad
    custom-nvm
    custom-fzf
)

DOTFILES="bashrc"

script_dir="$( cd "$(dirname "$([ -L "$0" ] && readlink -f "$0" || echo "$0")")" && pwd)"
# shellcheck disable=SC1090
source "$script_dir/../../util/os_util"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
fi
if [ "$SUDO_USER" == "" ]; then
    echo "Please run as sudo."
fi
HOME=/home/$SUDO_USER

for f in ${DOTFILES}; do
    rm -rf "/home/$SUDO_USER/.$f"
    sudo -H -u "$SUDO_USER" bash -c "ln -s ${script_dir}/$f /home/$SUDO_USER/.$f"
done

sudo apt update -y

for pkg in "${DEPS[@]}"; do
    # if [ "$pkg" ==  ]; then
    # fi

    if [ "$pkg" == custom-rust ]; then
        if ! bin_installed "/home/$SUDO_USER/.cargo/bin/rustup"; then
            sudo -H -u "$SUDO_USER" bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvim ]; then
        echo "custom neovim"
        if ! deb_installed "neovim"; then
            add-apt-repository -y ppa:neovim-ppa/stable
            apt update -y
            apt install -y neovim
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvchad ]; then
        if [ ! -d "/home/$SUDO_USER/.config/nvim" ]; then
            GIT_SSH_COMMAND="ssh -i /home/$SUDO_USER/.ssh/github" git clone git@github.com:gitbuda/NvChad.git "/home/$SUDO_USER/.config/nvim"
            chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config/nvim"
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvm ]; then
        if [ ! -d "/home/$SUDO_USER/.nvm" ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-fzf ]; then
        if [ ! -d "/home/$SUDO_USER/.fzf" ]; then
            git clone --depth 1 https://github.com/junegunn/fzf.git /home/$SUDO_USER/.fzf
            /home/$SUDO_USER/.fzf/install
            chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.fzf"
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-ssh-ident ]; then
        ssh_ident_folder="/home/$SUDO_USER/.local/ssh-ident"
        if [ ! -d "$ssh_ident_folder" ]; then
            GIT_SSH_COMMAND="ssh -i /home/$SUDO_USER/.ssh/github" git clone git@github.com:ccontavalli/ssh-ident.git "$ssh_ident_folder"
            chown -R "$SUDO_USER:$SUDO_USER" "$ssh_ident_folder"
            cd "$ssh_ident_folder"
            ln -s ssh-ident ssh
        fi
        echo "$pkg is installed." && continue
    fi

    if ! deb_installed "$pkg"; then
        apt install -y "$pkg"
    fi
    echo "$pkg is installed." && continue
done
