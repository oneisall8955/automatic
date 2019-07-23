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

if read -t 10 -p "yes/YES/Y/y 是否生成公钥私钥?" keygen
then
    keygen=`echo ${keygen} | tr '[a-z]' '[A-Z]'`
    info_var $LINENO "keygen"
    if [[ ${keygen} == "YES" || ${keygen} == "Y" ]];then
        ssh-keygen -t rsa
    fi
else
    warn "跳过生成公钥部分!"
fi

info "git安装检查..."
apt-get -y install git
info "检查完毕"
if read -t 10 -p "填写git用户名称!" name
then
    info_var $LINENO "name" "user.name"
    if [[ "${name}X" != "X" ]];then
        git config --global user.name "${name}"
    fi
else
    warn "跳过设置:git config --global user.name 'your name' "
fi

if read -t 10 -p "填写git用户名称!" email
then
    info_var $LINENO "email" "user.email"
    if [[ "${name}X" != "X" ]];then
        git config --global user.email "${email}"
    fi
else
    warn "跳过设置:git config --global user.name 'your name' "
fi

git config -l
sleep 5s

info "ssh && git 初始化完毕"