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
sleep 2s

while read line
do
    warn $LINENO ${line}
done <<< `cat << EOF
#如第一次登陆服务器,建议修改端口避免入侵!!!
#已修改则忽略提示

#1
#请修改 /etc/ssh/sshd_config 配置
#端口修改为22122
Port 22122

#2
#执行重置ssh.service
EOF
`
sleep 5s
echo ""
echo ""
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
sleep 2s
echo ""
echo ""
echo ""

info "git安装检查..."
apt-get -y install git
info "检查完毕"
echo ""
echo ""
echo ""

info "git 全局配置start..."
if read -t 10 -p "填写git用户名称(10秒后默认跳过此设置):" name
then
    info_var $LINENO "name" "user.name"
    if [[ "${name}X" != "X" ]];then
        git config --global user.name "${name}"
    fi
else
    warn "跳过设置:git config --global user.name 'your name' "
fi
sleep 2s

if read -t 10 -p "填写git用户名称(10秒后默认跳过此设置):" email
then
    info_var $LINENO "email" "user.email"
    if [[ "${name}X" != "X" ]];then
        git config --global user.email "${email}"
    fi
else
    warn "跳过设置:git config --global user.email 'your email' "
fi
info "git 全局配置end..."
sleep 2s
echo ""
echo ""
echo ""

info "请检测git配置..."
git config -l
sleep 5s

echo ""
echo ""
echo ""
info "ssh && git 初始化完毕"