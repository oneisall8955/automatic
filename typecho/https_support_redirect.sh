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
if [[ ! -f "${etc_profile}" ]] && [[ -z ${NGINX_CONF_DIR} ]] ;then
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

#param check
## $# < 2
if [[ $# -lt 2 ]] ;then
    error $LINENO "Usage : bash `basename $0` 'source.example.com' 'target.example.com'"
    exit 1
fi
source_domain=$1
target_domain=$2
source_domain_https_ssl_conf="${nginx_conf_dir}/${source_domain}_https_ssl.conf"
redirect_https_conf="${nginx_conf_dir}/${source_domain}.redirect_to_${target_domain}.conf"
info_var $LINENO "source_domain"
info_var $LINENO "target_domain"
info_var $LINENO "redirect_https_conf"
#backup
default_backup ${source_domain_https_ssl_conf}
default_backup ${redirect_https_conf}

#ssl file
cd ${nginx_conf_dir}/..
nginx_home=`pwd`
nginx_ssl_dir="${nginx_home}/ssl"
info_var $LINENO "nginx_home"
info_var $LINENO "nginx_ssl_dir"
if [[ ! -d "${nginx_ssl_dir}" ]]; then
    error $LINENO "nginx默认ssl证书配置文件夹不存在"
fi
cd ${execute_path}
certificate_file="${nginx_ssl_dir}/${source_domain}.zip"
if [[ ! -f ${certificate_file} ]];then
    error $LINENO "域名${source_domain}的证书压缩包${certificate_file}不存在"
    error $LINENO "请在${nginx_ssl_dir}下放置${source_domain}.zip认证文件!"
    exit 1
fi
certificate_unzip_dir="${nginx_ssl_dir}/${source_domain}"
info_var $LINENO "certificate_unzip_dir"
mkdir -p ${certificate_unzip_dir}
unzip -o -d ${certificate_unzip_dir} ${certificate_file}

ssl_crt_file="${certificate_unzip_dir}/Nginx/1_${source_domain}_bundle.crt"
ssl_key_file="${certificate_unzip_dir}/Nginx/2_${source_domain}.key"
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
cat > ${redirect_https_conf} << EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${source_domain};

    # 将 HTTP 请求重定向至 HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${source_domain};

    ssl_certificate ${ssl_crt_file};
    ssl_certificate_key ${ssl_key_file};

    return 301 https://${target_domain}\$request_uri;
}
EOF

#check && restart
set +e
nginx -t
if [[ $? == 0 ]];then
    systemctl restart nginx.service
    error "设置域名 ${source_domain} 跳转到 ${target_domain} 成功"
    exit 0
else
    error "设置域名 ${source_domain} 跳转到 ${target_domain} 失败,请检查原因重试"
    exit 1
fi
