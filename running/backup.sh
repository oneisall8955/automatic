#!/bin/bash -e

# log file
log_file="/opt/running/logs/backup.log"
# the directory for stored the archive
package_dir=/opt/backup/package
# total of package ervery task
backup_total=15
# the task for backup
task_array=("bitwarden" "typecho")

function backup_current(){
    task=$1
    now_time=`date +'%Y%m%d_%H_%M_%S'`
    /bin/echo "" >> ${log_file}
    /bin/echo "======" >> ${log_file}
    /bin/echo "当前时间:${now_time}" >> ${log_file}
    /bin/echo "开始:同步备份${task}" >> ${log_file}
    /usr/bin/rsync -avzP --password-file=/opt/running/config.d/rsyncd.pwd backup@129.204.126.34::${task} /opt/backup/current/${task}/ >> ${log_file} 2>&1
    /bin/echo "结束:同步备份${task}"  >> ${log_file}
    now_time=`date +'%Y%m%d_%H_%M_%S'`
    /bin/echo "当前时间:${now_time}" >> ${log_file}
    /bin/echo "======" >> ${log_file}
    /bin/echo ""  >> ${log_file}
}

function backup_package(){
    task=$1
    /bin/echo "" >> ${log_file}
    /bin/echo "======" >> ${log_file}
    /bin/echo "开始:打包${task}" >> ${log_file}
    begin_path=`/bin/pwd`
    cd /opt/backup/current/
    
    # package the archive
    /bin/mkdir -p ${package_dir}/${task}
    nowDate=`date +'%Y%m%d'`
    /bin/tar -zcf "${package_dir}/${task}/${task}_${nowDate}.tar.gz" ${task}

    # clear
    cd ${package_dir}/${task}/
    /bin/ls -t | grep "${task}_" | /usr/bin/awk 'NR>'"${backup_total}"'{print "rm -rf " $0}' | xargs /bin/rm -rf
    /bin/echo "结束:打包${task}" >> ${log_file}
    /bin/echo "最新备份文件(自动保留最新${backup_total}份)" >> ${log_file}
    /bin/ls -t | grep "${task}_" >> ${log_file}
    /bin/echo "======" >> ${log_file}
    /bin/echo ""  >> ${log_file}
    cd ${begin_path}
}

######################
# clear the log file #
######################
/bin/rm ${log_file}

####################
# backup real time #
####################
for job in ${task_array[@]}
do
    backup_current ${job}
done

###########################
# backup package everyday #
###########################
/bin/mkdir -p ${package_dir}

# now_time=20190912_10_21_15
n_time=`date +'%Y%m%d_%H_%M_%S'` # now time
s_time=`date +'%Y%m%d_00_00_00'` # start time
e_time=`date +'%Y%m%d_01_00_00'` # end time

/bin/echo "now time:${n_time}" >> ${log_file}
/bin/echo "sta time:${s_time}" >> ${log_file}
/bin/echo "end time:${e_time}" >> ${log_file}
if [[ ${n_time} > $s_time ]] && [[ ${now_time} < ${e_time} ]] ;then
    /bin/echo "时间是当天凌晨" >> ${log_file}
    /bin/echo "打包开始" >> ${log_file}
    for job in ${task_array[@]}
    do
        backup_package ${job}
    done
    /bin/echo "打包完毕" >> ${log_file}
else
    /bin/echo "时间不是当天凌晨,不打包" >> ${log_file}
fi
