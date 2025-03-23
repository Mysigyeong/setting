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
sudo apt install curl libfuse2 git ripgrep unzip -y

# Install neovim
mkdir -p $HOME/.local/bin 
curl -o $HOME/.local/bin/vi -L https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod u+x $HOME/.local/bin/vi

if [[ ! "$PATH" =~ "$HOME/.local/bin" ]]; then
    echo 'if [[ ! "$PATH" =~ "$HOME/.local/bin" ]]; then' >> $SHRC
    echo '    export PATH="$HOME/.local/bin:$PATH"' >> $SHRC
    echo 'fi' >> $SHRC
fi

# Install nerd font
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/UbuntuMono.zip
unzip -d UbuntuMono UbuntuMono.zip
mkdir -p $HOME/.local/share/fonts
cp UbuntuMono/*.ttf $HOME/.local/share/fonts/
fc-cache -f -v

# Install NvChad, LSPs, and DAP
mkdir -p $HOME/.config/
cp -r assets/nvchad_config $HOME/.config/nvim 

## Scala
### JDK 17
curl -LO https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz 
tar -zxvf openjdk-17.0.2_linux-x64_bin.tar.gz 
mkdir -p $HOME/.local 
mv jdk-17.0.2 $HOME/.local 
echo 'if [[ -z "$JAVA_HOME" ]]; then' >> $SHRC
echo '  export JAVA_HOME="$HOME/.local/jdk-17.0.2"' >> $SHRC  
echo '  export PATH="$JAVA_HOME/bin:$PATH"' >> $SHRC
echo 'fi' >> $SHRC 
rm openjdk-17.0.2_linux-x64_bin.tar.gz
export JAVA_HOME="$HOME/.local/jdk-17.0.2"  
export PATH="$JAVA_HOME/bin:$PATH"

### Metals
curl -fL "https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz" | gzip -d > cs
chmod +x cs
yes "n" | ./cs setup
echo 'if [[ ! "$PATH" =~ "$HOME/.local/share/coursier/bin" ]]; then' >> $SHRC
echo '  export PATH="$PATH:$HOME/.local/share/coursier/bin"' >> $SHRC
echo 'fi' >> $SHRC
./cs install metals
rm ./cs

## Rust
curl -o rust_installer.sh https://sh.rustup.rs -sSf
chmod +x rust_installer.sh
./rust_installer.sh -y
echo '. "$HOME/.cargo/env"' >> $HOME/.zshrc
. "$HOME/.cargo/env"
rm ./rust_installer.sh
rustup component add rust-analyzer

## C++
sudo apt install clang clangd bear cmake -y

## Python
sudo apt install python3 python3-pip -y
pip3 install pyright

## DAP
sudo apt install gdb -y
pip3 install debugpy
