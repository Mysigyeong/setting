#!/bin/bash 

# Abort immediately when error occurs
set -e

if [[ $SHELL =~ "bash" ]]; then
    SHRC=$HOME/.bashrc
elif [[ $SHELL =~ "zsh" ]]; then
    SHRC=$HOME/.zshrc
else
    echo "Unrecognized shell"
    exit 1
fi

# Install dependencies
sudo apt install curl libfuse2 git -y

# Install neovim
mkdir -p $HOME/.local/bin 
curl -o $HOME/.local/bin/vi -L https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x $HOME/.local/bin/vi

if [[ ! "$PATH" =~ "$HOME/.local/bin" ]]; then
    echo 'if [[ ! "$PATH" =~ "$HOME/.local/bin" ]]; then' >> $SHRC
    echo '    export PATH="$HOME/.local/bin:$PATH"' >> $SHRC
    echo 'fi' >> $SHRC
fi

# Install NvChad
git clone https://github.com/NvChad/starter $HOME/.config/nvim

# Install nerd font
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/UbuntuMono.zip
unzip -d UbuntuMono UbuntuMono.zip
mkdir -p $HOME/.local/share/fonts
cp UbuntuMono/*.ttf $HOME/.local/share/fonts/
fc-cache -f -v
