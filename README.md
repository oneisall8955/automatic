# automatic
### 简介
* **基于 `Debian`/`Ubuntu ` `(&&systemd)`系Linux自动化脚本**
* 重点在于学习shell脚本的编写及命令的熟悉,复习相关知识
* 如有错漏之处,敬请指正
###功能
* 有趣的基础脚本,如echo输出颜色,读取配置文件等工具
* 初始化系统的设置,如: `git`,`vim`,`ssh`,`zshell`,`oh-my-zsh`
* nginx自动编译安装(systemd service)
* Typecho & 主题 自动安装
* ...
### 相关规范
* 每个模块的使用方式:阅读模块里面的README.md,执行里面的install.sh/init.sh
* 软件安装路径:`/opt/software/`,如
    * 安装`nginx`,安装到`/opt/software/nginx/`
    * 安装`typecho`安装到`/opt/software/typecho`
    
* 安装软件后,如需要设置环境变量,则在`/etc/profile.d/`下创建对应软件的设置环境变量文件
    * 安装`nginx`,如需要设置nginx的配置include目录`NGINX_HOME_DIR=/opt/software/nginx/conf.d/`,则在`/etc/profile.d/`创建nginx_evn.sh
        ```bash
        cat /etc/profile.d/nginx_evn.sh
        NGINX_HOME=/opt/software/nginx
        NGINX_CONF_DIR=/opt/software/nginx/conf.d/
        export NGINX_CONF_DIR          
        ```
    * 安装`typecho`,如需要设置typecho的安装目录`TYPECHO_HOME=/opt/software/typecho`,
      则在`/etc/profile.d/`创建typecho_evn.sh
        ```bash
        cat /etc/profile.d/创建typecho_evn.sh
        TYPECHO_HOME=/opt/software/typecho
        export TYPECHO_HOME          
        ```

* 安装软件中,如遇到基础重复代码,可将代码抽取为方法,编写到`automatic/basic_shell.sh`,如
    * `echo` 带颜色作为提示信息
        ```bash
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
        #test
        echo_ yellow "hello world !"
        ```

* 安装过程中,如需要临时文件夹,统一输出到`/opt/temp`中,如
    * 安装nginx,解压`nginx-1.15.7.tar.gz`到`/opt/temp/nginx`
        ```bash
          tar -zxf nginx-1.15.7.tar.gz -C /opt/temp/nginx  
        ```