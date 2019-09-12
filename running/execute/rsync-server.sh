#!/bin/bash -e
# 备份:服务端运行 rsync 及配置
rsync --config /opt/running/config.d/rsyncd.conf --daemon
