"语法高亮
syntax on

"行号
set nu

"tab缩进
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab

"搜索相关
"匹配高亮度显示 
set hlsearch
"增查询回,回车确认定位
set incsearch
"忽略大小写
set ignorecase
set smartcase

"文件相关
set encoding=utf-8

"其他
set mouse=a

"键位映射
"-h 取消高亮搜索
nnoremap <silent> -h     :nohlsearch<CR>
