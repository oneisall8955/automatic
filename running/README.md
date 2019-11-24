# 一些服务器上运行的脚本

## 备份

> 以备份 bitwarden 为例

### 服务端
也就是需要被备份的服务器执行的步骤，在此称为服务端

**1.** 服务端创建 rsync 的配置文件 `/opt/running/config.d/rsyncd-server.conf`
如下，模板在 `automatic/running/config.d/rsyncd-server.conf`

```bash
uid=nobody
gid=nobody
max connections=10
pid file=/var/run/rsyncd.pid
lock file=/var/run/rsync.lock
log file=/var/run/rsyncd.log

[bitwarden]
path=/opt/software/bitwarden
comment=bitwarden docker & it's data
ignore errors
read only=true
list=false
uid=root
gid=root
auth users=backup
secrets file=/opt/running/config.d/rsyncd-server.pwd
```
如上，在配置节点 [bitwarden] 中，为服务端指定了一个备份任务叫 `bitwarden` 。
`path` 是备份任务 `bitwarden` 指定的备份的目录。
`auth users` 是 rsync 中，`bitwarden` 任务允许指定用户，这个用户并非系统的用户，是 rsync 自己定义的
`secrets file` 是 rsync `bitwarden` 任务指定的用户与密码文件存储的位置，下面步骤将介绍这个文件的格式

**2.** 服务端创建 rsync 的用户密码文件 `/opt/running/config.d/rsyncd-server.pwd`
如下，模板在 `automatic/running/config.d/rsyncd-server.pwd`

```bash
backup:123456
```
如上，用户及密码文件一行一个，以英文冒号隔开。这里只要配置了 `bitwarden` 任务指定的的用户

**3.** 服务端运行 rsync 服务
如下，模板在 `automatic/running/execute/rsync-server.sh`

```bash
rsync --config /opt/running/config.d/rsyncd.conf --daemon
```

如上，--config 指定了 rsync 的任务配置文件在哪， --daemon 参数是以后台进程模式运行 rsync

### 客户端
也就是异地备份的服务器执行的步骤，在此称为客户端

**1.** 客户端创建用户密码文本 `/opt/running/config.d/rsyncd-client.pwd`
如下，模板在 `automatic/running/config.d/rsyncd-client.pwd`

```bash
123456
```
这里只有一行，指定密码文本，也就是服务端创建 rsync 的用户密码文件 `/opt/running/config.d/rsyncd-server.pwd`
中指定的备份用户 `backup` 的密码：`12346`

**2.** 客户端创建备份脚本 `/opt/running/backup.sh`
如下，增强版按日备份，最多15天轮转备份脚本模板在 `automatic/running/backup.sh`
```bash
BACKUP_USER=backup
REMOTE_IP=192.168.3.10
CLIENT_PWD=/opt/running/config.d/rsyncd-client.pwd
LOG_FILE=/opt/running/logs/backup.log
TASK=bitwarden
BACKUP_DIR=/opt/backup/current
mkdir -p /opt/running/logs
mkdir -p /opt/backup/current
rsync -avzP --password-file=${CLIENT_PWD} ${BACKUP_USER}@${REMOTE_IP}::${TASK} ${BACKUP_DIR}/${TASK}/ >> ${LOG_FILE} 2>&1
```
如上，
`BACKUP_USER` 参数指定服务端指定的允许备份的用户；
`REMOTE_IP` 参数是服务端的 IP ；
`CLIENT_PWD` 参数指定这个用户的密码的文本在哪；
`LOG_FILE` 参数是日志文件；
`TASK` 参数指定任务名称，也就是服务端创建 rsync 的配置文件 `/opt/running/config.d/rsyncd-server.conf` 中的 `[bitwarden]` 节点
`BACKUP_DIR` 指定备份的目录在哪

执行的 rsync 命令 -avzP 具体网上搜索什么意思即可,相对简单

**3.** 客户端定时备份
如下 cron 中文件添加备份任务，模板在 `automatic/running/crontab.d/crontab.root`
```bash
crontab -e
## 添加任务如下，整点执行一次
0 * * * * /bin/bash /opt/running/backup.sh >> /opt/running/logs/backup.log 2>&1
```

**4.** 手动执行 `/opt/running/backup.sh` ，查看 `LOG_FILE` 文件日志，查看 `BACKUP_DIR` 文件夹中是否存在备份文件。
```bash
⇒ ls -l /opt/backup/current
drwxr-xr-x 3 root root 4096 10月 18 09:13 bitwarden
⇒ ll /opt/backup/current/bitwarden
-rwxr-xr-x 1 root root  178 10月 18 09:13 bitwarden-restart.sh
-rw-r--r-- 1 root root  132 9月   9 15:39 config.env
drwxr-xr-x 3 root root 4096 11月 24 12:48 data
-rw-r--r-- 1 root root  263 7月  29 18:06 docker-compose.yml
```
到此为止，如果备份文件夹存在则说明服务运行了。

**5.** 增加备份多个文件夹及轮转备份15天且压缩打包
查看 `automatic/running/backup.sh` 模板脚本，进行修改自定义即可。

**如有错漏之处,敬请指正，谢谢。**
