#! /bin/bash

# debian/ubuntu /var/log/auth.log
# rehat/centos  /var/log/secure
SSH_LOG_FILE=/var/log/auth.log

WORK_DIR="/opt/temp"
mkdir -p ${WORK_DIR}
BLACK_LIST_FILE=${WORK_DIR}/black.txt

# black ip count status
cat ${SSH_LOG_FILE}|awk '/Failed/{print $(NF-3)}'|sort|uniq -c|awk '{print $2"="$1;}' > ${BLACK_LIST_FILE}

# limit failed time
DEFINE=5

for element in `cat ${BLACK_LIST_FILE}`
do
    IP=`echo ${element} |awk -F= '{print $1}'`
    NUM=`echo ${element}|awk -F= '{print $2}'`

    # greater than limit
    if [ ${NUM} -gt ${DEFINE} ]; then
        # check if exist ? exist , return 0 ; not exist , return 1
        grep ${IP} /etc/hosts.deny > /dev/null
    fi
    # $? > 0 , it means : $NUM > $DEFINE and IP doesn't exist in /etc/hosts.deny
    if [ $? -gt 0 ]; then
        echo "sshd:${IP}" >> /etc/hosts.deny
    fi
done
sort -t= -k2 -n ${BLACK_LIST_FILE} > ${BLACK_LIST_FILE}_
mv ${BLACK_LIST_FILE}_ ${BLACK_LIST_FILE}