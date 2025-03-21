FROM ubuntu:24.04

LABEL org.opencontainers.image.authors="wbs79@kaist.ac.kr"

WORKDIR /root

RUN \
# Change archive source to kakao mirror
        apt update -y && \
        apt install ca-certificates -y && \
        sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list.d/ubuntu.sources && \
        sed -i 's/http/https/g' /etc/apt/sources.list.d/ubuntu.sources && \
        apt update -y && \
# Set timezone without interaction
        DEBIAN_FRONTEND=noninteractive apt install -y tzdata && \
        ln -snf /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
# apt upgrade
        apt upgrade -y

RUN \
# Install Oh My Zsh
        apt install curl zsh git tmux build-essential -y && \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
        chsh -s /bin/zsh && \
    # Configure Oh My Zsh
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" && \
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
        sed -i 's/^ZSH_THEME=.*$/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' $HOME/.zshrc && \
        sed -i 's/^plugins=.*$/plugins=(git zsh-autosuggestions colored-man-pages zsh-syntax-highlighting tmux)/g' $HOME/.zshrc && \
        echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> $HOME/.zshrc

COPY assets/my_p10k.zsh .p10k.zsh

RUN \
# Install NeoVIM
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
        tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
        ln -s /opt/nvim-linux-x86_64/bin/nvim /opt/nvim-linux-x86_64/bin/vi && \
        echo 'if [[ ! "$PATH" =~ "/opt/nvim-linux-x86_64/bin" ]]; then' >> $HOME/.zshrc && \
        echo '    export PATH="/opt/nvim-linux-x86_64/bin"' >> $HOME/.zshrc && \
        echo 'fi' >> $HOME/.zshrc && \
        rm nvim-linux-x86_64.tar.gz && \
        git clone https://github.com/NvChad/starter $HOME/.config/nvim
