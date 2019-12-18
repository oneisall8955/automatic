#!/bin/bash -e

cluster_dir="/opt/software/redis/cluster"
sta_port=20001
end_port=20006
conf_template="/opt/temp/redis/redis-4.0.10/redis.conf"

#port 9001（每个节点的端口号）
#daemonize yes
#bind 192.168.119.131（绑定当前机器 IP）
#dir /usr/local/redis-cluster/9001/data/（数据文件存放位置）
#pidfile /var/run/redis_9001.pid（pid 9001和port要对应）
#cluster-enabled yes（启动集群模式）
#cluster-config-file nodes9001.conf（9001和port要对应）
#cluster-node-timeout 15000
#appendonly yes

function fix(){
    
    port=${1}
    
    if [ -z ${port} ];then
        echo "error , port cannot empty !"
        exit 1
    fi

    echo "begin setting redis pid: ${port} ..."

    redis_dir=${cluster_dir}/${port}
    redis_conf=${redis_dir}/redis.conf
    cp ${conf_template} ${redis_conf}

    mkdir -p "${redis_dir}/data"

    # 69 bind 127.0.0.1
    # 92 port 6379
    # 136 daemonize no
    # 158 pidfile /var/run/redis_6379.pid
    # 263 dir ./ 
    # 672 appendonly no
    # 814 # cluster-enabled yes
    # 822 # cluster-config-file nodes-6379.conf
    # 828 # cluster-node-timeout 15000
    # 替换
    sed -i "69c bind 0.0.0.0" ${redis_conf}
    sed -i "92c port ${port}" ${redis_conf}
    sed -i "136c daemonize yes" ${redis_conf}
    sed -i "158c pidfile ${redis_dir}/redis_${port}.pid" ${redis_conf}
    sed -i "263c dir ${redis_dir}/data" ${redis_conf}
    sed -i "672c appendonly yes" ${redis_conf}
    sed -i "814c cluster-enabled yes" ${redis_conf}
    sed -i "822c cluster-config-file nodes-${port}.conf" ${redis_conf}
    sed -i "828c cluster-node-timeout 15000" ${redis_conf}

    echo "end setting redis : ${port} ..."
    echo ""
}

for index in `seq ${sta_port} ${end_port}`;do
    fix ${index}
done
