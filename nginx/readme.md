### 自动化安装nginx脚本
##### 前言:为什么会有此脚本
由于 `apt` / `yum` 安装的nginx在自己添加自定义模块麻烦(需要编译`deb` / `rpm`包),
作者对nginx编译仅在大学学习时练习,没有做相关笔记.况且`Linux`相关shell知识也是实习时锻炼出来,在现工作环境相关知识早已遗忘
本脚本在于复习nginx的编译,配置,及编译时一些模块的选择(https,ssl,)
##### 适用关于环境
* 支持的Linux发行版:Debian/Ubuntu
* 
##### 参考
[使用apt-get安装可选的Nginx模块][http://www.kbase101.com/question/55070.html]