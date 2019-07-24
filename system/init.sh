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

info "系统初始化ssh/git 开始..."
echo ""

cat << EOF
#如第一次登陆服务器,建议修改端口避免入侵!!!
#已修改则忽略提示

#1
#请修改 /etc/ssh/sshd_config 配置
#端口修改为22122
Port 22122

#2
#执行重置ssh.service
EOF

sleep 2s
echo ""

info "公私钥生成程序start..."
if read -t 10 -p "yes/YES/Y/y 是否生成公钥私钥(10秒后默认跳过此设置):" keygen
then
    keygen=`echo ${keygen} | tr '[a-z]' '[A-Z]'`
    info_var $LINENO "keygen"
    if [[ ${keygen} == "YES" || ${keygen} == "Y" ]];then
        ssh-keygen -t rsa
    else
        warn "选择不生成公钥私钥!"
    fi
else
    warn "跳过生成公钥部分!"
fi
info "公私钥生成程序end..."
sleep 1s
echo ""

info "git安装检查..."
if ! command_exists git; then
    apt-get -y install git
fi
info "安装检查完毕"
echo ""

info "git 全局配置start..."
if read -t 10 -p "是否设置git用户名称(10秒后默认跳过此设置)?(Y/n):" choice
then
    choice=`echo ${choice} | tr '[a-z]' '[A-Z]'`
    info_var $LINENO "choice" "配置git user.name?"
    if [[ "$choice" == "Y" || "${choice}" == "YES" ]];then
        read -p "请输如user.name的值:" name
        info_var $LINENO "name" "user.name"
        if [[ -n ${name} ]];then
            git config --global user.name "${name}"
        else
            warn "输入为空,取消设置user.name"
        fi
    fi
else
    warn "跳过设置:git config --global user.name 'your name' "
fi
sleep 1s


if read -t 10 -p "是否设置git邮箱(10秒后默认跳过此设置)?(Y/n):" choice
then
    choice=`echo ${choice} | tr '[a-z]' '[A-Z]'`
    info_var $LINENO "choice" "配置git user.email?"
    if [[ "$choice" == "Y" || "${choice}" == "YES" ]];then
        read -p "请输如user.email的值:" email
        info_var $LINENO "email" "user.email"
        if [[ -n ${email} ]];then
            git config --global user.email "${email}"
        else
            warn "输入为空,取消设置user.email"
        fi
    fi
else
    warn "跳过设置:git config --global user.email 'your email' "
fi

echo ""

info "请检测git配置..."
git config -l
sleep 1s

echo ""
info "ssh && git 初始化完毕"
echo ""

info "vim 配置start..."
if read -t 10 -p "是否配置vim(10秒后默认跳过此配置)?(Y/n):" choice
then
    choice=`echo ${choice} | tr '[a-z]' '[A-Z]'`
    info_var $LINENO "choice" "配置Vim?"
    if [[ "${choice}" == "Y" || "${choice}" == "YES" ]] ;then
        awesome_vimrc=${this_shell_dir}/.vimrc
        info_var $LINENO "awesome_vimrc"
        if [[ -z ${awesome_vimrc} || ! -f ${awesome_vimrc} ]];then
            error $LINENO ".vimrc不存在!"
            exit 1
        fi
        default_backup "~/.vimrc"
        cp ${awesome_vimrc} ~/.vimrc
        info "配置vim完成,配置如下"
        cat ~/.vimrc
        sleep 3s
    fi
else
    warn "跳过配置vim"
fi
echo ""
info "vim配置步骤结束"
echo ""

info $LINENO "本次初始化已结束"
info $LINENO "EOF"
