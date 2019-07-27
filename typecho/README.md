# typecho安装与nginx/https模块

### 使用步骤
1. 检查及配置nginx的配置目录
    > 如没有安装nginx,则执行automatic/nginx/install.sh进行自动安装,如已经安装了nginx,则配置nginx配置目录到nginx.conf,且将该目录设置为环境变量`NGINX_CONF_DIR`
    ```bash
   NGINX_CONF_DIR=${NGINX_CONF_DIR}
   echo ${NGINX_CONF_DIR}
   #如没有添加nginx统一配置目录环境变量,则需要配置一个nginx环境变量文件到/etc/profile.d/
   #touch /etc/profile.d/nginx_evn.sh
   #echo 'NGINX_HOME=/opt/software/nginx'  >> /etc/profile.d/nginx_evn.sh  #请修改为实际的nginx安装路径
   #echo 'NGINX_CONF_DIR=/opt/software/nginx/conf.d' >> /etc/profile.d/nginx_evn.sh #请修改为实际的nginx统一配置目录
   #echo 'export NGINX_HOME NGINX_CONF_DIR' >> /etc/profile.d/nginx_evn.sh 
    ```
2. 安装typecho
    ```bash
    cd automatic
    chmod +x typecho/install.sh
    ./typecho/install.sh
    ```
3. 配置typecho
    > 安装脚本默认生成typecho的nginx配置,端口为 `9528` \
      请保证服务器防火墙及云服务器的安全策略组开启9528端口的tcp访问, \
      如IP为 123.123.123.123,则登陆123.123.123.123:9528/install.php 进行初始化配置 \
      (配置typecho时,相关目录可能需要权限,如数据库目录及db文件,插件目录等 \
      请手动添加权限如 `chmod 766 /opt/software/typecho/usr`)
4. 配置https域名(非必需)
    > 请在云服务商申请证书,下载命名为 域名.zip 压缩包到 ${NGINX_HOME}/ssl/文件夹下 \
      使用 https_support.sh 脚本进行安装
    ```bash
    #nginx home
    NGINX_HOME=${NGINX_HOME}
    cd automatic
    chmod +x typecho/https_support.sh
    mkdir -p ${NGINX_HOME}/ssl/ #创建ssl凭证文件夹
 
    cp example.com.zip ${NGINX_HOME}/ssl/ #example.com的ssl凭证压缩包
    ./typecho/https_support.sh "example.com" #添加example.com访问博客主页
    
    cp www.example.com.zip ${NGINX_HOME}/ssl/ #www.example.com的ssl凭证压缩包
    ./typecho/https_support.sh "www.example.com" #添加www.example.com访问博客主页
 
    cp blog.example.com.zip ${NGINX_HOME}/ssl/ #blog.example.com的ssl凭证压缩包
    ./typecho/https_support.sh "blog.example.com" #添加blog.example.com访问博客主页
    ```
5. 配置https域名跳转(非必须)
    > 由于配合七牛云cdn,镜像源域名只能有一个,所以需要多个域名,统一跳转到指定域名进行cdn加速
      同样,每个域名都需要申请ssl证书.且建议在云解析将需要跳转的域名设置为cname到统一域名
    ```bash
    #nginx home
    NGINX_HOME=${NGINX_HOME}
    cd automatic
    chmod +x typecho/https_support_redirect.sh
    mkdir -p ${NGINX_HOME}/ssl/ #创建ssl凭证文件夹
 
    cp example.com.zip ${NGINX_HOME}/ssl/ #example.com的ssl凭证压缩包
    ./typecho/https_support.sh "example.com" #添加example.com访问博客主页
 
    cp www.example.com.zip ${NGINX_HOME}/ssl/ #www.example.com的ssl凭证压缩包
    ./typecho/https_support.sh "www.example.com" "example.com" # www.example.com 跳转到 example.com
 
    cp blog.example.com.zip ${NGINX_HOME}/ssl/ #blog.example.com的ssl凭证压缩包
    ./typecho/https_support.sh "blog.example.com" "example.com" # blog.example.com 跳转到 example.com
    ```
### typecho相关
* typecho位置安装在/opt/software/typecho
* 数据库使用sqlite,sqlite的版本是3.x
* nginx反向代理的配置在nginx配置目录`$NGINX_CONF_DIR`环境变量中,如无设置到则需要到`/etc/profile.d/`中新增一个专门设置nginx目录的配置文件,如`/etc/profile.d/nginx_evn.sh`

    ```bash
    root@VM-0-14-debian:/opt/temp|
    cat /etc/profile.d/nginx_evn.sh
    NGINX_CONF_DIR=/opt/software/nginx/conf.d
    export NGINX_CONF_DIR
    root@VM-0-14-debian:/opt/temp|
    echo ${NGINX_CONF_DIR}
    /opt/software/nginx/conf.d
    ```
* 外网typecho登陆地址:xxx.xxx.xxx.xxx:9528
* 配置时,一些typecho目录和文件可能需要一些权限,例如sqlite3的db,plugin等目录,当安装遇到执行不成功,尝试添加权限
* Mirages主题
    1. Mirages主题是商业付费主题,请在[Mirages商城](https://store.get233.com/)自行购买.本教程不包含此程序.
    2. 如需进行自动安装Mirages主题,则将下载到的 `Mirages-For-Typecho.zip` 解压后,修改 `1.主题` 为 `theme` , `2.插件` 修改为 `plugin` ,重新打包成 `Mirages-For-Typecho.tar.gz` 放在 `automatic/typecho/` 中
    3. 安装好后选择启用Mirages的主题和Mirages的插件方可生效
    4. Mirages主题需要一些特殊设置,详情请到[帮助文档](https://mirages.docs.get233.com)[必看文档-快速上手-必须的配置项](https://mirages.docs.get233.com/#/docs/quickstart/quick-start?id=%e5%bf%85%e9%a1%bb%e7%9a%84%e9%85%8d%e7%bd%ae%e9%a1%b9) 查看
    5. 解决插件冲突,如安装音乐插件 [APlayer](https://github.com/MoePlayer/APlayer-Typecho) ,需要特殊处理,详情请到帮助文档[高级设置-插件冲突解决方案](https://mirages.docs.get233.com)查看具体处理
* 音乐插件[APlayer](https://github.com/MoePlayer/APlayer-Typecho)的安装
    1. 本文作者使用的版本为`v2.0.5`,亲测可用
    3. 按照Aplayer的[README安装步骤](https://github.com/MoePlayer/APlayer-Typecho#安装)安装后,要谨慎检查该步骤 **修改文件夹名为 Meting**,否则文件夹名称不正确导致后端数据库操作异常
    2. 必须做好解决与Mirages插件的冲突!这是血的教训,没解决前页面无论如何都无法返回`正确的`音乐页面,导致Meting API自动调用失效
    3. 在插件管理,禁用/启用这个插件会提示数据库异常,意思是数据库表`metingv1`的Schema错误,这个重新第二次启用/禁用是可以正确启用/禁用操作的,莫慌
    4. 配置后端解析的API地址必须正确,可以用浏览器自测
    5. 要配合设置PAjax实现单页,才可以实现切换页面音乐不停止
    6. 换域名或开启https后,后端的解析API地址要换成正确的,如无更改需求,可以忽略该提醒
* 目前安装的主题及插件
    > 所有主题及插件均需要复制到对应位置重命名正确名称及到后台开启才生效!
    1. 主题: **Mirages**:[Mirages商城](https://store.get233.com/)
    2. 音乐: **Meting**:[Github](https://github.com/MoePlayer/APlayer-Typecho),[下载](https://codeload.github.com/MoePlayer/APlayer-Typecho/tar.gz/v2.0.5)
    3. 统计访问: **Access**:[Github](https://github.com/Vndroid/Access),[下载](https://codeload.github.com/Vndroid/Access/tar.gz/v2.0.8)
    4. 阅读量: **TePostViews**:[介绍](https://lixianhua.com/typecho_viewsnum_plugin.html),[下载](https://lixianhua.com/usr/uploads/2015/11/2267085321.rar),[下载-备用](https://cdn.get233.com/hran/2018/04/14/152368008908777_TePostViews_1.0.0.rar)
    5. 看板娘: **Pio**:[Github](https://github.com/Dreamer-Paul/Pio),[下载](https://codeload.github.com/Dreamer-Paul/Pio/zip/master)
* F12控制台显示个性提示
    1. 方法1,使用官方主题`设置外观`-`自定义 HTML 元素拓展`插入自定义展示代码
    2. 方法2,自定义插入脚本(不推荐)
        > 基于Mirages-1.7.10主题!!!
        1. 编辑${TYPECHO_HOME}/usr/themes/Mirages/component/footer.php
        2. 查找mirages.main.min.js关键字,(100行左右)
        3. 在改行下插入`<script src="<?php echo Content::jsUrl('custom_console_info.js')?>" type="text/javascript"></script>`,引入`custom_console_info.js`
        4. 复制`custom_console_info.js`到`${TYPECHO_HOME}/usr/themes/Mirages/js/1.7.10/custom_console_info.js`
        5. 修改复制的文件`${TYPECHO_HOME}/usr/themes/Mirages/js/1.7.10/custom_console_info.js`,修改为自己喜欢的打印语句
### 目录文件介绍
|file|description|
|:---|:---|
|1.1-17.10.30-release.tar.gz|typecho压缩包,解压得出build文件夹为typecho的安装目录,移动及重命名为到/opt/software/typecho即成为typecho的安装目录|
|blog.conf.template|默认生成的博客nginx配置,端口为9528|
|custom_console_info.js|控制台个性提示关键文件|
|https_support.sh|配置配置https域名关键文件|
|https_support_redirect.sh|配置https域名跳转关键文件|
|VOID.tar.gz|推荐的一个免费主题[VOID](https://blog.imalan.cn/)|