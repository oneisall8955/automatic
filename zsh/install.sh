#!/bin/bash -e
#find this shell's dir to include basic function
#ex:this_shell_dir=/root/automatic/zsh
execute_path=`pwd`
this_shell_dir=`dirname $0`
cd ${this_shell_dir}
this_shell_dir=`pwd`
cd ${this_shell_dir}/..
automatic_dir=`pwd`
cd ${execute_path}

#inclue basic function
source ${automatic_dir}/basic_shell.sh

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
apt install -y fonts-powerline

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
while read line
do
   echo_ yellow ${line}
done <<< `cat << EOF
#为了使用最新得支持,此处请手动更新 ~/.zshrc 以下内容
#推荐主题
#ZSH_THEME="robbyrussell"
#ZSH_THEME="agnoster"
ZSH_THEME="pygmalion"
#推荐插件
plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting last-working-dir)

#一些开关
#自动更正错误命令
ENABLE_CORRECTION="true"
#命令执行小红点进行提示
COMPLETION_WAITING_DOTS="true"
#自动更新提醒
DISABLE_UPDATE_PROMPT=true
#find命令查找指定目录下所有头文件时出现问题
setopt no_nomatch

#添加内容到文件底部!!!

alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias cls='clear'
alias -s html='vim' # 在命令行直接输入后缀为 html 的文件名，会在 Vim 中打开
alias -s rb='vim' # 在命令行直接输入 ruby 文件，会在 Vim 中打开
alias -s py='vim' # 在命令行直接输入 python 文件，会用 vim 中打开，以下类似
alias -s js='vim'
alias -s c='vim'
alias -s java='vim'
alias -s txt='vim'
alias -s gz='tar -xzvf' # 在命令行直接输入后缀为 gz 的文件名，会自动解压打开
alias -s tgz='tar -xzvf'
alias -s zip='unzip'
alias -s bz2='tar -xjvf'

#修复autojump 未生效 bug
[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && . ~/.autojump/etc/profile.d/autojump.sh

#修复Home/End 键在zsh中不起作用
bindkey "\033[1~" beginning-of-line
bindkey "\033[4~" end-of-line
EOF
`
echo ""
echo ""

#update /etc/zsh/zprofile
#support the file under the directory /etc/profile.d/
while read line
do
   echo_ yellow ${line}
done <<< `cat << EOF
#为了与 /bin/bash 此shell习惯一致,统一的环境变量配置,此处请手动添加以下内容到 /etc/zsh/zprofile
#读取/etc/profile.d文件夹下的*.sh文件
if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r \$i ]; then
      . \$i
    fi
  done
  unset i
fi
EOF
`

echo ""
info "安装完毕,请按以上提示修改!!!"
info "修改完毕后,请重开一个session以检查是否生效"