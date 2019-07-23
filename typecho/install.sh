#!/bin/bash
#find this shell's dir to include basic function
#ex:this_shell_dir=/root/automatic/typecho
execute_path=`pwd`
this_shell_dir=`dirname $0`
cd ${this_shell_dir}
this_shell_dir=`pwd`
cd ${this_shell_dir}/..
automatic_dir=`pwd`
cd ${execute_path}

#inclue basic function
source ${automatic_dir}/basic_shell.sh

#nginx
nginx_bin=`whereis nginx | awk '{print $2}'`
info_var $LINENO "nginx_bin"
if [[ "${nginx_bin}x" == "x" ]] ;then
    echo_ yelow "nginx 没有安装 正在安装..."
    nginx_install_shell="${automatic_dir}/nginx/install.sh"
    info_var $LINENO "nginx_install_shell"
    if [ ! -f ${nginx_install_shell} ]; then
        warn $LINENO "没有查找到nginx安装脚本:${nginx_install_shell}"
        exit 1
    fi
    chmod +x ${nginx_install_shell}
    bash ${nginx_install_shell}
    if [[ $? != 0 ]] ;then
        error $LINENO "nginx 安装失败!默认退出!"
        exit 1
    fi
    info $LINENO "nginx 安装完毕"
else
    nginx_pids=`ps -ef | grep "nginx" |grep -v "grep" |awk '{print $2}'`
    if [[ "${nginx_pids}x" == "x" ]] ;then
        warn $LINENO "检测没有开启nginx,正自动开启:systemctl start nginx.service"
        systemctl start nginx.service
    fi
    info $LINENO "nginx 检测完毕"
fi

#sqlite
dpkg -s sqlite3
if [[ $? != 0 ]] ;then
    warn $LINENO "sqlite 没有安装,开始安装sqlite..."
    apt-get -y install sqlite3
    info $LINENO "sqlite 安装完毕"
else
    info $LINENO "sqlite 检测完毕"
fi

#php
info $LINENO "检查安装:php-fpm php-cli php-common php-curl php-sqlite3 php-xml php-mbstring"
apt-get -y install php-fpm php-cli php-common php-curl php-sqlite3 php-xml
#ex:php7.0-fpm.service
php_fpm_service=`ls -lt /lib/systemd/system/ |grep 'fpm.service' | head -n 1 |awk '{print $NF}'`
if [[ "${php_fpm_service}x" == "x" ]] ;then
    error $LINENO "没有找到最新的phpXX-fpm.service,默认失败"
    error $LINENO "执行查找命令:ls -lt /lib/systemd/system/ |grep 'fpm.service' | head -n 1 |awk '{print $NF}'"
    exit 1
fi

php_fpm_pids=`ps -ef | grep "php-fpm" |grep -v "grep" |awk '{print $2}'`
if [[ "${php_fpm_pids}x" == "x" ]] ;then
    warn $LINENO "检测没有开启php-fpm,正自动开启:systemctl start ${php_fpm_service}"
    systemctl start ${php_fpm_service}
fi
info $LINENO "php,php-fpm 检测完毕"
systemctl enable ${php_fpm_service}


#typecho
typecho_package="${this_shell_dir}/1.1-17.10.30-release.tar.gz"
info_var $LINENO "typecho_package"
if [ ! -f ${typecho_package} ] ;then
    error $LINENO "typecho解压包不存在:${typecho_package}"
    exit 1
fi
typecho_home="/opt/software/typecho/"
mkdir -p ${typecho_home}
temp="/opt/temp/typecho"
mkdir -p ${temp}
rm -rf ${temp}/*
tar -xzf ${typecho_package} -C ${temp}
cp -r ${temp}/build/* ${typecho_home}/

info_var $LINENO "typecho_package"
info_var $LINENO "typecho_home"
info_var $LINENO "temp"

#find the nginx config dir
etc_profile="/etc/profile"
NGINX_CONF_DIR=${NGINX_CONF_DIR}
if [[ ! -f "${etc_profile}" ]] && [[ "${NGINX_CONF_DIR}X" == "X" ]];then
    error $LINENO "找不到:环境变量配置文件:${etc_profile},失败"
    exit 1
fi
source "/etc/profile"
nginx_conf_dir=${NGINX_CONF_DIR}
if [ ! -d ${nginx_conf_dir} ] ;then
    error $LINENO "nginx配置文件路径不存在:${nginx_conf_dir}"
    exit 1
fi
info_var $LINENO "nginx_conf_dir"

#php_fpm_service
#ex:php7.0-fpm.service
#php_sock=/run/php/php7.0-fpm.sock
php_sock=`echo ${php_fpm_service} | sed 's/.service/.sock/g'`
info_var $LINENO "php_sock"
domain_value="blog.liuzhicong.cn www.liuzhicong.cn liuzhicong.cn"
cat > ${nginx_conf_dir}/bolg.conf << EOF
server {
    listen 9528;
    listen [::]:9528;
    server_name _;
    index index.php index.html index.htm index.nginx-debian.html;
    root ${typecho_home};

    location / {
        try_files \$uri \$uri/ =404;
    }

    if (!-e \$request_filename) {
        rewrite ^(.*)$ /index.php\$1 last;
    }

    location ~ .*\\.php(\\/.*)*$ {
        include fastcgi.conf;
        fastcgi_pass unix:/run/php/${php_sock};
        include fastcgi_params;
    }

    location ~* \\.(db)$ {
        deny all;
    }
}
server {
    listen 80;
    listen [::]:80;
    server_name ${domain_value};
    index index.php index.html index.htm index.nginx-debian.html;
    root ${typecho_home};

    location / {
        try_files \$uri \$uri/ =404;
    }

    if (!-e \$request_filename) {
        rewrite ^(.*)$ /index.php\$1 last;
    }

    location ~ .*\\.php(\\/.*)*$ {
        include fastcgi.conf;
        fastcgi_pass unix:/run/php/${php_sock};
        include fastcgi_params;
    }

    location ~* \\.(db)$ {
        deny all;
    }
}
EOF

#The theme
theme_package=${this_shell_dir}/Mirages-For-Typecho.tar.gz
info_var $LINENO "theme_package" "主题压缩包"
temp="/opt/temp"
theme_unzip=${temp}/Mirages-For-Typecho
rm -rf ${theme_unzip}
info_var $LINENO "theme_unzip" "主题解压位置"
if [ ! -f "${theme_package}" ] ;then
    info $LINENO "主题压缩包:${theme_package} 不存在,跳过安装"
else
    tar -zxf ${theme_package} -C ${temp}
    theme=${theme_unzip}/theme
    plugin=${theme_unzip}/plugin
    if [ ! -d "${theme}" ] ;then
        error $LINENO "找不到解压后主题位置:${theme}"
        exit 1
    fi
    if [ ! -d "${plugin}" ] ;then
        error $LINENO "找不到解压后插件位置:${plugin}"
        exit 1
    fi
    cp -r ${theme}/* ${typecho_home}/usr/themes
    cp -r ${plugin}/* ${typecho_home}/usr/plugins
    chmod 777 ${typecho_home}/usr/themes/*
    chmod 777 ${typecho_home}/usr/plugins/*
    info $LINENO "安装typecho:Mirages-For-Typecho.tar.gz 主题成功"
fi
chmod 777 ${typecho_home}
custom_env_profile="/etc/profile.d/typecho_evn.sh"
echo "TYPECHO_HOME=${typecho_home}" >> ${custom_env_profile}
echo "export TYPECHO_HOME" >> ${custom_env_profile}
chmod +x ${custom_env_profile}

systemctl restart nginx.service
systemctl restart ${php_fpm_service}
