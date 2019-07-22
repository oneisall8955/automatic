/**

 Mirages_version=1.7.10
 TYPECHO_HOME=/opt/software/typecho/

 1.copy current js file file to ${TYPECHO_HOME}/usr/themes/Mirages/js/${version}/custom_console_info.js

 2. import it
 vim ${TYPECHO_HOME}/usr/themes/Mirages/component/footer.php
 search the code about importing mirages.main.min.js on the file footer.php ,maybe on 100 line.eg:
 100 # <script src="<?php echo Content::jsUrl('mirages.main.min.js')?>" type="text/javascript"></script>
 add this on the next line (maybe on 101 line),eg:
 101 # <script src="<?php echo Content::jsUrl('custom_console_info.js')?>" type="text/javascript"></script>

* */
let color="color: #fff; background-image: linear-gradient(90deg, rgb(47, 172, 178) 0%, rgb(45, 190, 96) 100%); padding:5px 1px;"
let bg="background-image: linear-gradient(90deg, rgb(45, 190, 96) 0%, rgb(255, 255, 255) 100%); padding:5px 0;"
function showInfo(title,msg){
    if(! msg){
        msg=title
        title=""
    }
    let info=""
    if(title){
        info="\n %c " + title + " %c " + msg
    }else{
        info="\n %c "+ msg + " %c "
    }
    info+="\n\n" ;
    console.log(info,color,bg);
}
try {
    if(window.console && window.console.log){
        showInfo("########## blog.liuzhicong.cn","##########");
        showInfo("性感博主","在线解码(BASE 64)");
        showInfo("E-mail","b25laXNhbGw4OTU1QGdtYWlsLmNvbQ==");
        showInfo("Wechat","TUFYLTAyMjE=");
        showInfo("Github","aHR0cHM6Ly9naXRodWIuY29tL29uZWlzYWxsODk1NQ==");
    }
} catch (e) {}