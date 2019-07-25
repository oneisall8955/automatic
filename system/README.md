# system 初始化
### 使用方式
```bash
cd automatic
chmod +x system/init.sh
./system/init.sh
```
### 初始化的内容
1. 提示ssh修改端口
2. 是否生成公钥私钥
3. 检查安装Git
4. 是否配置git中的user.name/user.mail
5. 是否配置vim

### 文件列表及描述
|file|description|
|:---|:---|
|.vimrc|vim的初始化配置文件|
|custom-env-path.sh|jdk/gradle/maven等环境变量的配置,复制到/etc/profile.d/|