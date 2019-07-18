#!/bin/bash -e
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

function info(){
    echo_ green "[INFO]  -- : $*"
}

function warn(){
    echo_ yellow "[WARN]  -- : $*"
}

function error(){
    echo_ red "[ERROR] -- : $*"
}

function info_var(){
    var_name=$1
    var_value=$(eval echo '$'$1)
    title=$2
    if [[ "${title}X" != "X" ]] ;then
        title="${title}:"
    fi
    info "${title}${var_name}:${var_value}"
}

#get value in properties file 
#Usage:get_properties $file $key
log_file="/opt/temp/get_properties.log"
function get_properties(){
mkdir -p "/opt/temp"
rm -rf ${log_file}
    file=$1
    key=$2
    value=""
    if [[ "${file}X" == "X" || ! -f ${file} || "${key}X" == "X" ]];then
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
            echo [${key_in_properties}]=[${value_in_properties}] >> ${log_file}
            if [[ $key == ${key_in_properties} ]];then
                value=${value_in_properties}
                break
            fi
            # 必须使用 while read line; do done; <<< "xxx"/`excute result` 这种形式!!! cat xxx | while read line 管道这种形式变量作用域会再推出循环后失效!!!
        done <<< `cat ${file} | grep -v "^[ \t]*\#" | grep -v "^$" |awk '{ if($1!="") print $0 }'|awk -F '=' '{ if($2!="") print $0 }'`
        echo "search:${key} in $file,value=${value}" >> ${log_file}
    fi
    echo ${value}
}
function get_properties_error(){
cat > $log_file <<EOF
    File no exist or key is empty,return empty string
    Usage:get_properties file key
    Example:get_properties /opt/temp/user.properties name
EOF
}
