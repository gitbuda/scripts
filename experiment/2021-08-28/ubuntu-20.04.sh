#!/bin/bash -e

DEPS=(
    htop tmux vim tree curl git libssl-dev
    google-chrome-stable
    custom-fonts
    # Install neovim from source because v0.5+ is required.
    ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl
    dconf-cli uuid-runtime
    # Install One Dark with https://github.com/Mayccoll/Gogh
    # Terminal Profile Setup: FiraMono Medium Regular 11, One Dark Theme, Show scrollbar OFF.
    # Put #ABB2BF as a Default Text Color
    custom-neovim custom-nvchad
    clang clang-format
    ripgrep
    custom-rust
    custom-nvm
    custom-docker
)

script_dir="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
# shellcheck disable=SC1090
source "$script_dir/../../util/os_util"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
fi
if [ "$SUDO_USER" == "" ]; then
    echo "Please run as sudo."
fi

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
        if [ ! -d /home/$SUDO_USER/.config/nvim ]; then
            GIT_SSH_COMMAND="ssh -i /home/$SUDO_USER/.ssh/github" git clone git@github.com:gitbuda/NvChad.git /home/$SUDO_USER/.config/nvim
            chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.config/nvim
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-fonts ]; then
        cd "$script_dir"
        # Use fc-list to see the list of all installed fonts.
        if [ ! -f FiraMono.zip ]; then
            wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraMono.zip -O FiraMono.zip
            unzip FiraMono.zip -d /home/$SUDO_USER/.fonts
            fc-cache -fv
        fi
        echo "$pkg is installed." && continue
    fi

    if [ "$pkg" == custom-nvm ]; then
        if [ ! -d /home/$SUDO_USER/.nvm ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
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
            usermod -aG docker $SUDO_USER
            newgrp docker
        fi
        echo "$pkg is installed." && continue
    fi

    if ! deb_installed "$pkg"; then
        apt install -y "$pkg"
    fi
    echo "$pkg is installed." && continue
done
