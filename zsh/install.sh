#!/bin/bash -e

#install zsh
apt-get -y install zsh
#change shell to zsh
chsh -s /bin/zsh

#oh-my-zsh
#git for cloning the oh-my-zsh
apt-get -y install git
#install ...
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
#fonts
apt install fonts-powerline

#helpful tools
#autojump
apt-get -y install autojump

#plugins
#zsh custom directory
ZSH_CUSTOM=${ZSH_CUSTOM:-'~/.oh-my-zsh/custom'}
#zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
#zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting

#update .zshrc

#support the file under the directory /etc/profile.d/
