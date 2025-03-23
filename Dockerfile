FROM ubuntu:24.04

LABEL org.opencontainers.image.authors="wbs79@kaist.ac.kr"

WORKDIR /root

# Change archive source to kakao mirror
# Set timezone without interaction
RUN \
        apt update -y && \
        apt install ca-certificates sed -y && \
        sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list.d/ubuntu.sources && \
        sed -i 's/http/https/g' /etc/apt/sources.list.d/ubuntu.sources && \
        apt update -y && \
        DEBIAN_FRONTEND=noninteractive apt install -y tzdata && \
        ln -snf /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
        apt upgrade -y

# Install Oh My Zsh
RUN \
        apt install curl zsh git tmux build-essential ripgrep unzip tar gzip -y && \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
        chsh -s /bin/zsh && \
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" && \
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
        sed -i 's/^ZSH_THEME=.*$/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' $HOME/.zshrc && \
        sed -i 's/^plugins=.*$/plugins=(git zsh-autosuggestions colored-man-pages zsh-syntax-highlighting tmux)/g' $HOME/.zshrc && \
        echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> $HOME/.zshrc

COPY assets/my_p10k.zsh .p10k.zsh

# Install NeoVIM
RUN \
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
        tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
        ln -s /opt/nvim-linux-x86_64/bin/nvim /opt/nvim-linux-x86_64/bin/vi && \
        echo 'if [[ ! "$PATH" =~ "/opt/nvim-linux-x86_64/bin" ]]; then' >> $HOME/.zshrc && \
        echo '    export PATH="/opt/nvim-linux-x86_64/bin:$PATH"' >> $HOME/.zshrc && \
        echo 'fi' >> $HOME/.zshrc && \
        rm nvim-linux-x86_64.tar.gz

# Install NvChad, LSPs, and DAP
COPY assets/nvchad_config .config/nvim

## Scala
### Install JDK 17
RUN \
        curl -LO https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz && \
        tar -zxvf openjdk-17.0.2_linux-x64_bin.tar.gz && \
        mkdir -p $HOME/.local && \
        mv jdk-17.0.2 $HOME/.local && \
        echo 'if [[ -z "$JAVA_HOME" ]]; then' >> $HOME/.zshrc && \
        echo '  export JAVA_HOME="$HOME/.local/jdk-17.0.2"' >> $HOME/.zshrc && \ 
        echo '  export PATH="$JAVA_HOME/bin:$PATH"' >> $HOME/.zshrc && \
        echo 'fi' >> $HOME/.zshrc && \
        rm openjdk-17.0.2_linux-x64_bin.tar.gz

ENV JAVA_HOME=/root/.local/jdk-17.0.2 \
    PATH=/root/.local/jdk-17.0.2/bin:$PATH

### Install Metals
RUN \
        curl -fL "https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz" | gzip -d > cs && \
        chmod +x cs && \
        yes "n" | ./cs setup && \
        echo 'if [[ ! "$PATH" =~ "$HOME/.local/share/coursier/bin" ]]; then' >> $HOME/.zshrc && \ 
        echo '  export PATH="$PATH:$HOME/.local/share/coursier/bin"' >> $HOME/.zshrc && \
        echo 'fi' >> $HOME/.zshrc && \
        ./cs install metals && \
        rm ./cs

### Install Rust Analyzer
RUN \
        curl -o rust_installer.sh https://sh.rustup.rs -sSf && \
        chmod +x rust_installer.sh && \
        ./rust_installer.sh -y && \
        echo '. "$HOME/.cargo/env"' >> $HOME/.zshrc && \
        . "$HOME/.cargo/env" && \
        rm ./rust_installer.sh && \
        rustup component add rust-analyzer

### Install Clangd
RUN apt install clang clangd bear cmake -y

### Install Pyright
RUN \
        apt install python3 python3-pip -y && \
        pip3 install pyright --break-system-packages

### Install DAP 
RUN \
        apt install gdb -y
        pip3 install debugpy --break-system-packages
