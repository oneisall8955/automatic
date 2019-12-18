#!/bin/bash -e

# make PREFIX=/opt/software/redis/redis-single install

redis_version=4.0.10
download_dir="/opt/download"
temp_dir="/opt/temp/redis"
redis_home="/opt/software/redis/single"
redis_port=20000
redis_password=123456
redis_service="redis4single.service"

url="http://download.redis.io/releases/redis-${redis_version}.tar.gz"
redis_zip_name=redis-${redis_version}.tar.gz
conf_template="${temp_dir}/redis-${redis_version}/redis.conf"
redis_conf=${redis_home}/redis.conf
redis_service_template=${temp_dir}/${redis_service}
redis_pid=${redis_home}/redis_${redis_port}.pid

function get_zip(){
    mkdir -p ${download_dir}
    cd ${download_dir}
    download_file=${download_dir}/${redis_zip_name}
    if [ -e "${download_file}" ];then
        echo "${download_file} already exists , skip download"
    else
        wget ${url} -O ${redis_zip_name}
    fi
}


function compile(){
    cp ${download_dir}/${redis_zip_name} ${temp_dir}/
    cd ${temp_dir}
    tar -zxf ${redis_zip_name}
    cd redis-${redis_version}
    make PREFIX=${redis_home} install
}

function config(){
    # 检查    
    if [ -z ${redis_port} ];then
        echo "error , port cannot empty !"
        exit 1
    fi

    echo "begin setting redis pid: ${redis_port} ..."

    cp ${conf_template} ${redis_conf}

    mkdir -p "${redis_home}/data"

    # 69 bind 127.0.0.1
    # 92 port 6379
    # 136 daemonize no
    # 158 pidfile /var/run/redis_6379.pid
    # 263 dir ./
    # 500 requirepass foobared
    # 672 appendonly no
    # 替换
    sed -i "69c bind 0.0.0.0" ${redis_conf}
    sed -i "92c port ${redis_port}" ${redis_conf}
    sed -i "136c daemonize yes" ${redis_conf}
    sed -i "158c pidfile ${redis_pid}" ${redis_conf}
    sed -i "263c dir ${redis_home}/data" ${redis_conf}
    sed -i "500c requirepass ${redis_password}" ${redis_conf}
    sed -i "672c appendonly yes" ${redis_conf}

    echo "end setting redis : ${redis_port} ..."
    echo ""
}

function service(){
	cat > ${redis_service_template} <<EOF
[Unit]
Description=Redis
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=${redis_pid}
ExecStart=${redis_home}/bin/redis-server ${redis_conf}
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
	cp ${redis_service_template} /usr/lib/systemd/system/
	systemctl daemon-reload
	systemctl enable ${redis_service}
}

function run(){
	systemctl restart ${redis_service}
}

function main(){
    get_zip
    compile
    config
    service
    run
}

main
