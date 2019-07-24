# 自动化安装nginx脚本
### 前言:为什么会有此脚本?
由于 `apt` / `yum` 安装的nginx在自己添加自定义模块麻烦(需要编译`deb` / `rpm`包),
作者对nginx编译仅在大学学习时练习,没有做相关笔记.况且`Linux`相关shell知识也是实习时锻炼出来,在现工作环境中相关知识早已遗忘
故此目录下的脚本目的在于复习nginx的编译,配置
### 环境相关
* 适用Linux发行版: `Debian/Ubuntu`
* nginx版本: `1.15.7`
* nginx安装目录: `/opt/software/nginx/`
* nginx加载配置目录: `/opt/software/nginx/conf.d/`
* nginx环境变量文件: `/etc/profile.d/nginx_evn.sh`
* 环境变量中的变量与值: 

    |key|value|description|
    | :--- | :--- | :--- |
    |NGINX_HOME|/opt/software/nginx|nginx home|
    |NGINX_CONF_DIR|/opt/software/nginx/conf.d/|include conf folder|
* 默认编译nginx配置
  > prefix,http_ssl_module,http_v2_module :\
  > --prefix=/opt/software/nginx \\ \
   --with-http_ssl_module \\ \
   --with-http_v2_module 
   
### 使用方式
```bash
# 进入本项目automatic文件夹
cd automatic
# 赋予执行权限
chmod +x automatic/nginx/install.sh
# 执行安装nginx/install.sh脚本
./automatic/nginx/install.sh
```

### 一些必要知识及扩展
1. 编译时候没有指定安装目录,那么默认安装路径生成的配置文件在哪里?(假设安装目录为变量`NGINX_HOME`)
   1. 打开configure文件,查看源码`NGX_PREFIX=${NGX_PREFIX:-/usr/local/nginx}`默认安装在`/usr/local/nginx`
   2. 类似地,nginx默认启动的config在`${NGINX_HOME}/conf/nginx.conf`
   3. 编译出来的可执行二进制文件在`nginx`在 `${NGINX_HOME}/sbin/nginx`,由于该目录,没有加入环境变量,为了方便执行该二进制文件,
   故需要在 `/usr/bin` 或 `/usr/sbin` 或 `/usr/local/bin` 或`/usr/local/bin` 或 `/usr/local/sbin`等文件夹下做一个链接,
   如: `ln -s ${nginx_home}/sbin/nginx /usr/bin/nginx`
   4. 默认日志在 `${NGINX_HOME}/logs/`, PID保存在 `${NGINX_HOME}/logs/pid`
2. **为了增加模块,需要重新编译,应该怎么做?需要注意点什么?**
   1. `cd` 到`nginx解压包根路径`
      > cd /opt/temp/nginx/nginx-1.15.7 
   2. 重新编译 `./configure --xxx=xxx --xxx=xxx --with-xxx_module`
      > ./configure --with-http_ssl_module --with-http_v2_module
   3. 执行 `make` !!! 仅仅执行 `make` !!! 不需要 `make install` ,否则覆盖之前的二进制执行文件
      > make
   4. 备份原来的nginx可执行文件
      > mv ${NGINX_HOME}/sbin/nginx ${NGINX_HOME}/sbin/nginx_bak \
      或使用default_backup函数进行备份
   5. 复制编译的二进制文件到你的nginx安装目录(objs目录为解压包中执行`configure`编译后的结果目录)
      > cp ./objs/nginx /usr/local/nginx/sbin/
3. 查看编译配置参数和及其作用描述
   1. 查看编译参数 : nginx -V
   2. 查看参数描述,到解压目录下执行 ./configure --help
4. nginx需要统一的一个文件夹存储自定义的nginx配置,本项目默认为`${NGINX_HOME}/conf.d` 文件夹
    (以debian系列开发版通过 apt-get install nginx安装风格相同),
    同时在`nginx.conf`中使用`include  ${NGINX_HOME}/conf.d/*.conf` 语句进行导入
5. 编写systemd service管理nginx的状态:安装脚本将自动生成(或修改模板导入到 `/lib/systemd/system/nginx.service`)

### 本目录其他文件作用

|file|description|
| :---: | :---: |
|nginx.service.template|systemd管理nginx的启动,重启,停止,查看状态等|
|nginx.conf.template|${NGINX_HOME}/conf/nginx.config的默认生成简化后的模板,可以自行修改|
|domain.conf_https_ssl.template|指定域名https模板|
|domain.conf_https_ssl_redirect.template|指定A域名https跳转到指定B域名https模板|
    
### 参考
* [使用apt-get安装可选的Nginx模块](http://www.kbase101.com/question/55070.html)