#!/bin/bash -e

DEPS=(
    htop tmux vim tree curl git libssl-dev tig
    # https://wiki.archlinux.org/title/SSH_keys -> a very nice read about SSH keys.
    # https://unix.stackexchange.com/questions/90853/how-can-i-run-ssh-add-automatically-without-a-password-prompt
    # ssh-ident seems very interesting for the server side use-case.
    openssh-server keychain gnupg-agent custom-ssh-ident
    python-is-python3 # REQUIRED_BY: ssh-ident
    python3-dbg
    ansible
    google-chrome-stable
    custom-fonts
    # Install neovim from source because latest is required.
    ninja-build gettext libtool libtool-bin autoconf automake cmake cmake-curses-gui g++ pkg-config unzip curl
    dconf-cli uuid-runtime
    # Install One Dark with https://github.com/Mayccoll/Gogh
    # Terminal Profile Setup: FiraMono Medium Regular 11, One Dark Theme, Show scrollbar OFF.
    # Put #ABB2BF as a Default Text Color
    custom-neovim custom-nvchad
    clang clang-format
    ripgrep
    shellcheck
    gpick gimp inkscape
    powerstat powertop lm-sensors
    dos2unix
    mlocate
    custom-conda
    custom-cuda
    custom-rust
    custom-nvm
    custom-docker
    custom-tpm
    custom-fzf
)

DOTFILES="bashrc tmux.conf gdbinit"

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

function install_font {
    download_link=$1
    local_file_name=$2
    if [ ! -f "$local_file_name" ]; then
        wget "$download_link" -O "$local_file_name"
        mkdir -p "/home/$SUDO_USER/.fonts"
        unzip "$local_file_name" -d "/home/$SUDO_USER/.fonts"
        fc-cache -fv
    fi
}

for pkg in "${DEPS[@]}"; do
    # if [ "$pkg" ==  ]; then
    # fi

    if [ "$pkg" == google-chrome-stable ]; then
        if ! deb_installed "$pkg"; then
            wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
            echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
	    apt update
	    apt -y install google-chrome-stable
        fi
	echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-rust ]; then
        if ! bin_installed "/home/$SUDO_USER/.cargo/bin/rustup"; then
            sudo -H -u "$SUDO_USER" bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-neovim ]; then
	if ! bin_installed "$script_dir/neovim/build/bin/nvim"; then
            cd "$script_dir"
            git clone https://github.com/neovim/neovim
            cd neovim && make -j4 && make install
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

    if [ "$pkg" == custom-fonts ]; then
        cd "$script_dir"
        # Use fc-list to see the list of all installed fonts.
        install_font "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraMono.zip" "FiraMono.zip"
        install_font "https://www.cufonfonts.com/download/font/encode-sans-semi-condensed" "EncodeSansSemiCondensed.zip"
        install_font "https://dl.dafont.com/dl/?f=roboto" "Roboto.zip"
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvm ]; then
        if [ ! -d "/home/$SUDO_USER/.nvm" ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | sudo -H -u "$SUDO_USER" bash
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-docker ]; then
        if ! deb_installed "docker-ce"; then
            apt update
            apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt update
            apt install -y docker-ce docker-ce-cli containerd.io
            curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
            usermod -aG docker "$SUDO_USER"
            newgrp docker
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-tpm ]; then
        tpm_repo="https://github.com/tmux-plugins/tpm"
        tpm_dir="/home/$SUDO_USER/.tmux/plugins/tpm"
        if [[ ! -d "${tpm_dir}" ]]; then
            git clone "${tpm_repo}" "${tpm_dir}"
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

    if [ "$pkg" == custom-conda ]; then
        if [ ! -d "/home/$SUDO_USER/.fzf" ]; then
            cd "$script_dir"
            wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.out
            chmod +x miniconda.out
            ./miniconda.out
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-cuda ]; then
        if [ ! -d "/usr/local/cuda" ]; then
            cd "$script_dir"
            wget https://developer.download.nvidia.com/compute/cuda/11.6.0/local_installers/cuda_11.6.0_510.39.01_linux.run -O cuda.out
            sh cuda.out
        fi
        echo "$pkg is installed." && continue
    fi

    if ! deb_installed "$pkg"; then
        apt install -y "$pkg"
    fi
    echo "$pkg is installed." && continue
done
