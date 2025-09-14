#!/bin/bash
# 设置命令提示符样式
PS1='\u@\h:\w\$ ' # \u: 用户名, \h: 主机名, \w: 当前工作目录

# 启用命令别名
alias ll='ls -lah' # 以长格式列出文件并显示隐藏文件，与 zshrc 一致
alias la='ls -A'   # 列出所有文件和目录，但不包括 . 和 ..
alias l='ls -CF'   # 简化的文件列表显示
alias gs='git status' # 查看 git 状态的快捷方式，与 zshrc 一致
alias ..='cd ..'   # 返回上一级目录，与 zshrc 一致

# 设置历史记录
HISTFILE=~/.histfile       # 设置历史记录文件路径，与 zshrc 一致
HISTSIZE=10000             # 设置命令历史记录的最大条数
HISTFILESIZE=10000         # 设置历史记录文件的最大条数
HISTCONTROL=ignoredups     # 忽略重复的命令
shopt -s histappend        # 追加历史记录而不是覆盖
PROMPT_COMMAND='history -a' # 每次命令执行后保存历史记录

# 自动补全功能
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion # 加载系统的 bash 自动补全功能
fi

# 自定义环境变量
export EDITOR='vim' # 设置默认文本编辑器为 vim
export PATH="$HOME/bin:$PATH" # 将用户自定义的 bin 目录加入 PATH

# 启用颜色支持
export CLICOLOR=1 # 启用终端颜色
export LSCOLORS=GxFxCxDxBxegedabagaced # 自定义 ls 命令的颜色

# 防止文件覆盖
set -o noclobber # 禁止使用 > 覆盖已有文件

# 启用别名扩展
shopt -s expand_aliases # 允许在脚本中使用别名

# 提高命令历史记录的安全性
shopt -s histappend # 追加历史记录而不是覆盖
PROMPT_COMMAND='history -a' # 每次命令执行后保存历史记录

# 自定义 PS1 提示符颜色
PS1='\[\e[32m\]\u@\h:\[\e[34m\]\w\[\e[0m\]\$ ' # 绿色用户名@主机名，蓝色当前路径

# 添加常用函数
# 快速导航到项目目录
function proj() {
    cd ~/projects/$1 # 切换到 ~/projects 下的指定目录
}

# 清理临时文件
function clean() {
    rm -rf /tmp/* # 删除 /tmp 目录下的所有文件
    echo "临时文件已清理"
}


