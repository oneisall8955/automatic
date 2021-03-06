#!/bin/bash -e

#find this shell's dir to include basic function
#ex:this_shell_dir=/root/automatic/nginx
execute_path=`pwd`
this_shell_dir=`dirname $0`
cd ${this_shell_dir}
this_shell_dir=`pwd`
cd ${execute_path}

#inclue basic function
source ${this_shell_dir}/../basic_shell.sh

#install dependencies
apt update
info $LINENO "安装以下程序:gcc,unzip"
apt-get -y install gcc unzip

info $LINENO "安装以下程序:openssl,libssl-dev"
apt-get -y install openssl libssl-dev

info $LINENO "安装以下程序:libpcre3,libpcre3-dev"
apt-get -y install libpcre3 libpcre3-dev

info $LINENO "安装以下程序:zlib1g-dev"
apt-get -y install zlib1g-dev

echo ""

#some path necessary
temp='/opt/temp/nginx'
nginx_version="1.15.7"
nginx_package="${this_shell_dir}/nginx-${nginx_version}.tar.gz"
nginx_home="/opt/software/nginx"

info_var $LINENO "nginx_version"
info_var $LINENO "nginx_package"
info_var $LINENO "nginx_home"
info_var $LINENO "temp"

mkdir -p ${nginx_home}
mkdir -p ${temp}
rm -rf ${temp}/*

if [ ! -f ${nginx_package} ] ;then
    error $LINENO "nginx 压缩包不存在:${nginx_package}"
    exit 1
fi

tar -zxf ${nginx_package} -C ${temp}

if [ ! -f ${temp}/nginx-${nginx_version}/configure ] ;then
    error $LINENO "nginx configure 不存在:${temp}/nginx-${nginx_version}/configure"
    echo 1
fi

cd ${temp}/nginx-${nginx_version}
#编译配置
nginx_configure="--prefix=${nginx_home}"
# --with-http_ssl_module
# --with-http_v2_module
# --
nginx_configure="${nginx_configure} --with-http_ssl_module --with-http_v2_module"

info $LINENO "nginx编译配置如下:"
info_var $LINENO "nginx_configure"
sleep 3s

./configure ${nginx_configure}

make && make install >/dev/null

default_backup `whereis nginx | awk -F ':' '{print $2}'`
ln -s ${nginx_home}/sbin/nginx /usr/bin/nginx

cat > /lib/systemd/system/nginx.service <<EOF
# Stop dance for nginx
# =======================
#
# ExecStop sends SIGSTOP (graceful stop) to the nginx process.
# If, after 5s (--retry QUIT/5) nginx is still running, systemd takes control
# and sends SIGTERM (fast shutdown) to the main process.
# After another 5s (TimeoutStopSec=5), and if nginx is alive, systemd sends
# SIGKILL to all the remaining processes in the process group (KillMode=mixed).
#
# nginx signals reference doc: # http://nginx.org/en/docs/control.html
#
[Unit]
Description=A high performance web server and a reverse proxy server
After=network.target

[Service]
Type=forking
PIDFile=${nginx_home}/logs/nginx.pid
ExecStartPre=${nginx_home}/sbin/nginx -t -q -g 'daemon on; master_process on;'
ExecStart=${nginx_home}/sbin/nginx -g 'daemon on; master_process on;'
ExecStartPost=/bin/sleep 1
ExecReload=${nginx_home}/sbin/nginx -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile ${nginx_home}/logs/nginx.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF

if [ -f ${nginx_home}/conf/nginx.conf ] ;then
    mv ${nginx_home}/conf/nginx.conf ${nginx_home}/conf/nginx.conf.init_bak
fi
nginx_conf_dir="${nginx_home}/conf.d"
info_var $LINENO "nginx_conf_dir"
mkdir -p ${nginx_conf_dir}
cat > ${nginx_home}/conf/nginx.conf << EOF
user  www-data;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

    include  ${nginx_conf_dir}/*.conf;
}
EOF

systemctl daemon-reload
systemctl start nginx.service
systemctl enable nginx.service

#environment variable
custom_env_profile="/etc/profile.d/nginx_evn.sh"
info_var $LINENO "custom_env_profile" "nginx环境变量配置文件"
NGINX_CONF_DIR=${nginx_conf_dir}
info_var $LINENO "NGINX_CONF_DIR"
info $LINENO "设置环境变量 NGINX_CONF_DIR=${NGINX_CONF_DIR} 到 ${custom_env_profile} 文件"
echo "NGINX_CONF_DIR=${nginx_conf_dir}" > ${custom_env_profile}
echo "export NGINX_CONF_DIR" >> ${custom_env_profile}
NGINX_HTTPS_SUPPORT=${chose_https}
info_var $LINENO "NGINX_HTTPS_SUPPORT"
echo "NGINX_HTTPS_SUPPORT=${NGINX_HTTPS_SUPPORT}"
info $LINENO "设置环境变量 NGINX_HTTPS_SUPPORT=${NGINX_HTTPS_SUPPORT} 到 ${custom_env_profile} 文件"
echo "export NGINX_HTTPS_SUPPORT" >> ${custom_env_profile}
echo "echo 'export nginx evn finish ... (this msg from ${custom_env_profile})'" >> ${custom_env_profile}

chmod +x ${custom_env_profile}

info $LINENO "${custom_env_profile}文件如下:"
warn $LINENO "---------------------------"
cat ${custom_env_profile} | while read line
do
    echo_ yellow ${line}
done
warn $LINENO "---------------------------"

echo ""
source ${custom_env_profile}
echo ""

info $LINENO "已成功安装nginx,退出"
