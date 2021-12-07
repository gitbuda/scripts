#!/bin/bash -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dotfiles="bashrc bash_aliases ctags gitconfig gitignore tmux.conf zshrc"

for f in ${dotfiles}; do
    rm -rf "$HOME/.$f"
    ln -s "${script_dir}/dotfiles/$f" "$HOME/.$f"
done

## Dependencies setup.
# Tmux Plugin Manager setup.
tpm_repo="https://github.com/tmux-plugins/tpm"
tpm_dir="$HOME/.tmux/plugins/tpm"
if [[ ! -d "${tpm_dir}" ]]; then
    git clone "${tpm_repo}" "${tpm_dir}"
fi

# TODO: Add conda bashrc setup
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/buda/Programs/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/buda/Programs/miniconda3/etc/profile.d/conda.sh" ]; then
#        . "/home/buda/Programs/miniconda3/etc/profile.d/conda.sh"
#    else
#        export PATH="/home/buda/Programs/miniconda3/bin:$PATH"
#    fi
#fi
#unset __conda_setup
# <<< conda initialize <<<
