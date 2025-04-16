" 设置编码为UTF-8
set encoding=utf-8

" 显示行号
set number " 显示绝对行号
set relativenumber " 显示相对行号

" 设置缩进
set tabstop=4       " 一个Tab等于4个空格
set shiftwidth=4    " 自动缩进使用4个空格
set expandtab       " 将Tab替换为空格
set autoindent      " 自动对齐当前行的缩进

" 启用语法高亮
syntax on " 开启语法高亮

" 设置搜索
set ignorecase      " 搜索时忽略大小写
set smartcase       " 如果搜索中包含大写字母，则区分大小写
set hlsearch        " 高亮搜索结果
set incsearch       " 输入搜索内容时实时显示匹配结果

" 显示光标所在行和列
set cursorline      " 高亮当前行
set cursorcolumn    " 高亮当前列

" 设置状态栏
set laststatus=2    " 始终显示状态栏

" 启用鼠标支持
set mouse=a         " 启用鼠标在所有模式下使用

" 设置备份和撤销
set backup          " 启用备份文件
set undofile        " 启用撤销文件
set undodir=~/.vim/undo " 设置撤销文件存储路径

" 设置文件编码
set fileencodings=utf-8,gbk " 优先使用UTF-8编码，其次是GBK

" 设置分屏
set splitright      " 新的垂直分屏在右侧打开
set splitbelow      " 新的水平分屏在下方打开

" 设置滚动
set scrolloff=8     " 光标上下保留8行
set sidescrolloff=8 " 光标左右保留8列

" 设置颜色主题
colorscheme desert  " 使用desert颜色主题

" 自动保存视图
autocmd BufWinLeave * mkview
autocmd BufWinEnter * silent! loadview

" 自定义快捷键
nnoremap <leader>w :w<CR> " 保存文件
nnoremap <leader>q :q<CR> " 退出文件
nnoremap <leader>x :x<CR> " 保存并退出文件