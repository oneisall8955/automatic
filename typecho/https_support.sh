#!/bin/bash -e
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

#find the nginx config dir
etc_profile="/etc/profile"
NGINX_CONF_DIR=${NGINX_CONF_DIR}
if [[ ! -f ${etc_profile} ]] && [[ -z ${NGINX_CONF_DIR} ]];then
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

TYPECHO_HOME=${TYPECHO_HOME}
info_var $LINENO "TYPECHO_HOME"
if [[ -z ${TYPECHO_HOME} ]] || [[ ! -d ${TYPECHO_HOME} ]] ;then
    error $LINENO "typecho路径不存在:${TYPECHO_HOME}"
    exit 1
fi

domain=$1
info_var $LINENO "domain" "输入的域名"
if [[ -z ${domain} ]]; then
    error $LINENO "请传递域名!!!"
    error $LINENO "Usage: bash https_support.sh 'hello.example.com'"
    exit 1
fi
cd ${nginx_conf_dir}/..
nginx_home=`pwd`
nginx_ssl_dir="${nginx_home}/ssl"
info_var $LINENO "nginx_home"
info_var $LINENO "nginx_ssl_dir"
if [[ ! -d "${nginx_ssl_dir}" ]]; then
    error $LINENO "nginx默认ssl证书配置文件夹不存在"
fi
cd ${execute_path}
certificate_file="${nginx_ssl_dir}/${domain}.zip"
if [[ ! -f ${certificate_file} ]];then
    error $LINENO "域名${domain}的证书压缩包${certificate_file}不存在"
    error $LINENO "请在${nginx_ssl_dir}下放置${domain}.zip"
    exit 1
fi

#check if nginx support https ?
nginx -V
NGINX_HTTPS_SUPPORT=${NGINX_HTTPS_SUPPORT:-0}
info_var $LINENO "NGINX_HTTPS_SUPPORT"
if [[ ${NGINX_HTTPS_SUPPORT} != 1 ]]; then
    warn "当前nginx可能没有安装https模块!"
    warn "如已经安装Https支持,请在/etc/profile.d/目录下添加相关profile文件设置NGINX_HTTPS_SUPPORT=1"
    if read -t 10 -p "yes/YES/Y/y选择忽略警告,继续安装?10s后不输入默认不安装" continue_install
    then
        continue_install=`echo ${continue_install} | tr '[a-z]' '[A-Z]'`
        if [[ ${continue_install} == "YES" || ${continue_install} == "Y" ]];then
            info_var $LINENO "continue_install"
            warn "选择忽略警告,继续安装!!!"
        else
            info_var $LINENO "continue_install"
            warn "选择停止安装,默认退出"
            exit 0
        fi
    else
        warn "默认不安装"
        exit 0
    fi
fi

#check ssl certificate
#domain=liuzhicong.cn
#-- blog.liuzhicong.cn.zip
#---- blog.liuzhicong.cn.csr
#---- Nginx/
#------ 1_blog.liuzhicong.cn_bundle.crt
#------ 2_blog.liuzhicong.cn.key
#---- Apache/
#------ ......
#------ ......
certificate_unzip_dir="${nginx_ssl_dir}/${domain}"
info_var $LINENO "certificate_unzip_dir"
mkdir -p ${certificate_unzip_dir}
unzip -o -d ${certificate_unzip_dir} ${certificate_file}
blog_conf="${nginx_conf_dir}/blog.conf"
info_var $LINENO "blog_conf" "原博客配置文件"
now_time=`date +'%Y%m%d_%H%M%S'`
if [[ -f "${blog_conf}" ]]; then
    blog_bak_file="${blog_conf}.bak_${now_time}"
    mv ${blog_conf} "${blog_bak_file}"
    info_var $LINENO "blog_bak_file"
    info $LINENO "成功备份原始博客:配置文件:${blog_conf}->${blog_bak_file}"
fi
ssl_crt_file="${certificate_unzip_dir}/Nginx/1_${domain}_bundle.crt"
ssl_key_file="${certificate_unzip_dir}/Nginx/2_${domain}.key"
info_var $LINENO "ssl_crt_file" "ssl证书:crt文件"
info_var $LINENO "ssl_key_file" "ssl证书:key文件"
if [[ ! -f ${ssl_crt_file} ]] || [[ ! -f ${ssl_key_file} ]]; then
    error $LINENO "解压包异常!crt文件/key文件不存在"
    set +e
    info $LINENO "解压包文件列表如下"
    ls -l ${certificate_unzip_dir}
    set -e
    exit 1
fi
domain_https_ssl_conf="${nginx_conf_dir}/${domain}_https_ssl.conf"
php_fpm_service=`ls -lt /lib/systemd/system/ |grep 'fpm.service' | head -n 1 |awk '{print $NF}'`
php_sock=`echo ${php_fpm_service} | sed 's/.service/.sock/g'`
info_var $LINENO "domain_https_ssl_conf"
info_var $LINENO "php_fpm_service"
info_var $LINENO "php_sock"
if [[ -f "${php_sock}"  ]]; then
    error $LINENO "sock 文件不存在"
    exit 1
fi
if [[ -f "${domain_https_ssl_conf}" ]]; then
    conf_bak_file=${domain_https_ssl_conf}.bak_${now_time}
    mv ${domain_https_ssl_conf} "${conf_bak_file}"
    info_var $LINENO "conf_bak_file"
    info $LINENO "成功备份原始domain:${domain}配置文件:${domain_https_ssl_conf}->${conf_bak_file}"
fi


cat > ${domain_https_ssl_conf} << EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${domain};

    # 将 HTTP 请求重定向至 HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${domain};
    index index.php index.html index.htm index.nginx-debian.html;
    root ${TYPECHO_HOME};

    ssl_certificate ${ssl_crt_file};
    ssl_certificate_key ${ssl_key_file};
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on;

    add_header Strict-Transport-Security max-age=15768000;

    ssl_stapling on;

    location / {
            try_files \$uri \$uri/ =404;
    }

    if (!-e \$request_filename) {
            rewrite ^(.*)$ /index.php\$1 last;
    }

    location ~ .*\.php(\/.*)*$ {
            include fastcgi.conf;
            fastcgi_pass unix:/run/php/${php_sock};
            include fastcgi_params;
    }

    # 防止数据库文件被下载
    location ~* \.(db)$ {
             deny all;
    }
}
EOF

systemctl restart nginx.service
