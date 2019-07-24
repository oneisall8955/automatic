# typecho安装与nginx/https模块

### 使用步骤
1. 安装typecho
    ```bash
    
    ```
2. 配置typecho

3. 配置https域名(非必需)

### 关于typecho与Mirages主题
* typecho位置安装在/opt/software/typecho
* 数据库使用sqlite,sqlite的版本是3.x
* nginx反向代理的配置在nginx配置目录`$NGINX_CONF_DIR`环境变量中,如无设置到则需要到`/etc/profile.d/`中新增一个专门设置nginx目录的配置文件,如`/etc/profile.d/nginx_evn.sh`

    ```bash
    root@VM-0-14-debian:/opt/temp|
    cat /etc/profile.d/nginx_evn.sh
    NGINX_CONF_DIR=/opt/software/nginx/conf.d
    export NGINX_CONF_DIR
    echo 'export nginx evn finish ... (this msg from /etc/profile.d/nginx_evn.sh)'
    root@VM-0-14-debian:/opt/temp|
    echo ${NGINX_CONF_DIR}
    /opt/software/nginx/conf.d
    ```
* 外网typecho登陆地址:xxx.xxx.xxx.xxx:9528
* 安装目录需要一些权限,例如sqlite3的db
* 数据库文件
* 关于Mirages主题
    1. Mirages主题是商业付费主题,请在[Mirages商城](https://store.get233.com/)自行购买.本教程不包含此程序.
    2. 如需进行自动安装Mirages主题,则将下载到的 `Mirages-For-Typecho.zip` 解压后,修改 `1.主题` 为 `theme` , `2.插件` 修改为 `plugin` ,重新打包成 `Mirages-For-Typecho.tar.gz` 放在 `automatic/typecho/` 中
    3. 安装好后选择启用Mirages的主题和Mirages的插件方可生效
    4. Mirages主题需要一些特殊设置,详情请到[帮助文档](https://mirages.docs.get233.com)[必看文档-快速上手-必须的配置项](https://mirages.docs.get233.com/#/docs/quickstart/quick-start?id=%e5%bf%85%e9%a1%bb%e7%9a%84%e9%85%8d%e7%bd%ae%e9%a1%b9) 查看
    5. 解决插件冲突,如安装音乐插件 [APlayer](https://github.com/MoePlayer/APlayer-Typecho) ,需要特殊处理,详情请到帮助文档[高级设置-插件冲突解决方案](https://mirages.docs.get233.com)查看具体处理
* 关于音乐插件[APlayer](https://github.com/MoePlayer/APlayer-Typecho)的安装
    1. 本文作者使用的版本为`v2.0.5`,亲测可用
    3. 按照Aplayer的[README安装步骤](https://github.com/MoePlayer/APlayer-Typecho#安装)安装后,要谨慎检查该步骤 **修改文件夹名为 Meting**,否则文件夹名称不正确导致后端数据库操作异常
    2. 必须做好解决与Mirages插件的冲突!这是血的教训,没解决前页面无论如何都无法返回`正确的`音乐页面,导致Meting API自动调用失效
    3. 在插件管理,禁用/启用这个插件会提示数据库异常,意思是数据库表`metingv1`的Schema错误,这个重新第二次启用/禁用是可以正确启用/禁用操作的,莫慌
    4. 配置后端解析的API地址必须正确,可以用浏览器自测
    5. 要配合设置PAjax实现单页,才可以实现切换页面音乐不停止
    6. 换域名或开启https后,后端的解析API地址要换成正确的,如无更改需求,可以忽略该提醒
