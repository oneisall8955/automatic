# zsh&oh-my-zsh
### 使用
```bash
cd automatic
chmod +x zsh/install.sh
./zsh/install.sh
```
### oh-my-zsh相关
修改~/.zshrc
##### 修改主题
> ZSH_THEME="pygmalion"
##### 修改插件
zsh-autosuggestions zsh-syntax-highlighting 在install.sh中已经安装到custom文件夹中
> plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting last-working-dir)
##### 修改一些BUG
主要是zsh与bash不兼容,导致一些命令失败,如find命令查找指定目录下所有头文件时出现问题
> setopt no_nomatch
##### 好用的alias
```bash
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
```
##### bash风格,一致的环境变量文件夹
将以下代码添加到/etc/zsh/zprofile
```bash
if [ -d /etc/profile.d ]; then
    for i in /etc/profile.d/*.sh; do
      if [ -r ${i} ]; then
        . ${i}
      fi
    done
unset i
fi
``` 
##### 完整的~/.zshrc配置
```bash
#推荐主题
#ZSH_THEME="robbyrussell"
#ZSH_THEME="agnoster"
ZSH_THEME="pygmalion"
#推荐插件
plugins=(git autojump zsh-autosuggestions zsh-syntax-highlighting last-working-dir)

#一些开关
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
```
##### pygmalion主题统一风格
修改~/.oh-my-zsh/themes/pygmalion.zsh-theme,将40改成0,即提示的字符大于0的时候就换行,避免提示格式不一致
```bash
if [[ $prompt_length -gt 0 ]]; then

    nl=$'\n%{\r%}';

  fi
PROMPT="$base_prompt$gitinfo$nl$post_prompt"
```