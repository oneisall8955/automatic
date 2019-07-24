#!/bin/bash -e
#log file dir
mkdir -p "/opt/temp"
#function
red="\033[31m"  ## red
green="\033[32m" ## green
yellow="\033[33m" ## yellow
end_="\033[0m" #end

function echo_(){
    color=$1
    start_="\033[0m"
    case ${color} in
    "red")
        start_=${red}
        ;;
    "green")
        start_=${green}
        ;;
    "yellow")
        start_=${yellow}
        ;;
    *)
        ;;
    esac
    shift
    msg=$*
    echo -e "${start_}${msg}${end_}"
}
format_log="/opt/temp/format.log"
function format_(){
    line_no=$1
    echo "line_no=${line_no}" > ${format_log}
    shift
    echo "$ *=$*" >> ${format_log}
    msg="$*"
    echo "msg=${msg} check ..." >> ${format_log}
    if [[ -z ${msg} ]] ;then
        echo "msg is empty.let msg=line_no,line_no=\"\"" >> ${format_log}
        msg=${line_no}
        line_no=""
    fi
    echo "line_no=${line_no} check..." >> ${format_log}
    if [[ -z ${line_no} ]] ;then
        result=`printf "[%5d]-${msg}\n" 0`
        echo "line_no is empty,result=${result}" >> ${format_log}
    else
        result=`printf "[%5d]-${msg}\n" ${line_no}`
        echo "line_no no empty,result=${result}" >> ${format_log}
    fi
    echo "${result}"
}

function info(){
    msg=`format_ "$@"`
    echo_ green "[INFO]  -- : ${msg}"
}

function warn(){
    msg=`format_ "$@"`
    echo_ yellow "[WARN]  -- : ${msg}"
}

function error(){
    msg=`format_ "$@"`
    echo_ red "[ERROR] -- : ${msg}"
}

#aaa=AAA
#info_var "aaa"
#info_var $LINENO "aaa"
#info_var "aaa" "aaa's value"
#info_var $LINENO "aaa" "aaa's value"
info_var_log="/opt/temp/info_var.log"
function info_var(){
    rm -rf ${info_var_log}
    line_no=""
    var_name=""
    var_value=""
    title=""
    #0个参数
    if [[ $# == 0 ]];then
        info "0" > /dev/null
    fi
    #1个参数
    if [[ $# == 1 ]];then
        var_name=$1
    fi
    #2个参数
    if [[ $# == 2 ]];then
        type=`echo $1 | grep [^0-9] >/dev/null && echo "NOT_INT" || echo "INT"`
        info $LINENO "DEBUG---type=${type}" >> ${info_var_log}
        if [[ ${type} == 'INT' ]];then
            #info_var $LINENO "aaa"
            line_no=$1
            var_name=$2
        else
            #info_var "aaa" "aaa's value"
            var_name=$1
            title=$2
        fi
    fi
    #大于等于3个参数,忽略第4个及后面的
    if [[ $# -ge 3 ]];then
        line_no=$1
        var_name=$2
        title=$3
    fi
    info $LINENO "DEBUG---var_name=$var_name" >> ${info_var_log}
    var_value=`eval echo '$'"${var_name}"`
    if [[ -n ${title} ]] ;then
        title="${title}:"
    fi
    info ${line_no} "${title}[${var_name}=${var_value}]"
}

#get value in properties file
#Usage:get_properties $file $key
log_file="/opt/temp/get_properties.log"
function get_properties(){
    rm -rf ${log_file}
    file=$1
    key=$2
    value=""
    if [[ -z ${file} || ! -f ${file} || -z ${key} ]];then
        get_properties_error
    else
        while read line
        do
            key_in_properties=${line%=*}
            #trim
            key_in_properties=`echo ${key_in_properties}`
            value_in_properties=${line##*=}
            #trim
            value_in_properties=`echo ${value_in_properties}`
            echo "[${key_in_properties}]=[${value_in_properties}]" >> ${log_file}
            if [[ ${key} == ${key_in_properties} ]];then
                value=${value_in_properties}
                break
            fi
            # 必须使用 while read line; do done; <<< "xxx"/`execute result` 这种形式!!! cat xxx | while read line 管道这种形式变量作用域会再退出循环后失效!!!
        done <<< `cat ${file} | grep -v "^[ \t]*\#" | grep -v "^$" |awk '{ if($1!="") print $0 }'|awk -F '=' '{ if($2!="") print $0 }'`
        echo "search:${key} in $file,value=${value}" >> ${log_file}
    fi
    echo ${value}
}

#log for get properties
function get_properties_error(){
cat > ${log_file} <<EOF
    File no exist or key is empty,return empty string
    Usage:get_properties file key
    Example:get_properties /opt/temp/user.properties name
EOF
}

#backup file
#aaa.txt - > aaa.txt_20190719_201251
function default_backup(){
    info "备份文件流程开始(不支持文件夹)..."
    if [[ $# -le 0 ]];then
        error "Usage default_backup 'file_a.txt' 'file_b.txt'"
        return 0
    fi
    now_time=`date +'%Y%m%d_%H%M%S'`
    info_var "now_time"
    for file in "$@"
    do
        info_var "file" "传递的备份文件名称"
        file_base_name=`basename ${file}`
        info_var "file_base_name"
        file_dir_name=`dirname ${file}`
        if [[ ${file_dir_name} == '~' ]];then
            file_dir_name=${HOME}
        fi
        info_var "file_dir_name"
        file=${file_dir_name}/${file_base_name}
        info_var "file" "兼容的真实备份文件路径"
        if [[ -f ${file} ]];then
            backup_file="${file}.bak_${now_time}"
            info_var "backup_file" "${file}备份文件"
            mv ${file} ${backup_file}
        else
            error "待备份文件${file}不存在,跳过备份"
        fi
    done
    return 0
}


command_exists() {
    command -v "$@" >/dev/null 2>&1
}
