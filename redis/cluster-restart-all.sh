#!/bin/bash -e

ip=110.120.130.140
cluster_dir="/opt/software/redis/cluster"
sta_port=20001
end_port=20006

function restart_redis(){
    port=${1}
    echo "begin restart redis ${port}"
    
    # 检查是否开启
    echo "netstat -ap|egrep ${port} |awk '{print \$7}' |awk -F '/' '{print \$1}'"
    pid=`netstat -ap|egrep ${port} |awk '{print $7}' |awk -F '/' '{print $1}'`
	echo "pid :${pid}"

	# 存在则杀掉进程
	if [ -z "${pid}" ] ; then
    	echo "目标进程不存在，直接启动"
	else
    	echo "目标进程 PID=${pid}"
	    kill -9 ${pid}
    	echo "PID ${pid} 已被执行kill"
	    echo "休眠1s ..."
    	sleep 1s
	fi

	# 启动 redis
    ${cluster_dir}/bin/redis-server ${cluster_dir}/${port}/redis.conf

    echo "end restart redis ${port}"
    echo ""
}

array=()
loop=0
function restart_all(){
    for index in `seq ${sta_port} ${end_port}`;do
        restart_redis ${index}
        array[${loop}]="${ip}:${index}"
        let loop+=1
    done
}

function join(){
    local IFS="$1";
    shift;
    echo "$*";
}

function create_cluster(){
    cluster_flag=${cluster_dir}/.cluster_success
    if [ -e ${cluster_flag} ];then
        echo "检测已存在集群记录，跳过创建集群"
    else
        echo "检测不存在集群记录，删除数据"
        ports=`join , ${array}`
        rm ${cluster_dir}/{${ports}}/data/* -f
        ${cluster_dir}/bin/redis-trib.rb create --replicas 1 ${array[@]}
    fi
    now_time=`date +'%Y%m%d_%H%M%S'`
    echo "create success ! ${now_time}" > ${cluster_flag}
}

function main(){
    restart_all
    create_cluster
}

main
