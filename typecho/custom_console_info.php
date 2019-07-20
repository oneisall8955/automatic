<?php if(1) : ?>
    <script type="text/javascript">
        color="color: #fff; background-image: linear-gradient(90deg, rgb(47, 172, 178) 0%, rgb(45, 190, 96) 100%); padding:5px 1px;"
        bg="background-image: linear-gradient(90deg, rgb(45, 190, 96) 0%, rgb(255, 255, 255) 100%); padding:5px 0;"
        function showInfo(title,msg){
            if(! msg){
                msg=title
                title=""
            }
            var info=""
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
    </script>
<?php endif;?>
