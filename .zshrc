# 设置默认的 shell 提示符
# %n - 用户名, %m - 主机名, %~ - 当前目录
export PS1='%n@%m:%~ %# '

# 启用命令自动更正
# 自动更正输入错误的命令
setopt CORRECT

# 启用不区分大小写的补全
# 使 Tab 补全忽略大小写
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# 启用扩展的通配符匹配
# 允许高级模式的模式匹配
setopt EXTENDED_GLOB

# 设置默认编辑器
# 更改为您喜欢的编辑器 (例如 vim, nano)
export EDITOR='vim'

# 添加自定义目录到 PATH
# 包含额外的可执行文件目录
export PATH="$HOME/bin:$PATH"

# 定义别名
# 常用命令的快捷方式
alias ll='ls -lah'  # 以长格式列出文件并显示隐藏文件
alias gs='git status'  # 查看 git 状态的快捷方式
alias ..='cd ..'  # 返回上一级目录

# 启用会话间的历史记录共享
# 在所有终端会话中共享命令历史记录
setopt SHARE_HISTORY

# 设置历史记录文件大小
# 控制存储在历史记录中的命令数量
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# 启用语法高亮 (需要 zsh-syntax-highlighting 插件)
# 为命令语法提供视觉反馈
if [ -f "$HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# 启用自动建议 (需要 zsh-autosuggestions 插件)
# 根据历史记录建议命令
if [ -f "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# 启用 Powerlevel10k 主题 (需要安装 powerlevel10k)
if [ -f "$HOME/.config/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source "$HOME/.config/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme"
elif [ -f /usr/share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme ]; then
    source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
fi

# 如果有自定义的 p10k 配置文件，加载它
if [ -f ~/.p10k.zsh ]; then
    source ~/.p10k.zsh
fi

# 加载自定义脚本 (如果有)
# 包含额外的脚本或配置
if [ -d "$HOME/.zshrc.d" ]; then
    for script in "$HOME/.zshrc.d"/*.zsh; do
        [ -r "$script" ] && source "$script"
    done
fi

# 案件绑定 
# 绑定 Home 键跳转到行首
bindkey '^[[H' beginning-of-line
bindkey '^[[1~' beginning-of-line

# 绑定 End 键跳转到行尾
bindkey '^[[F' end-of-line
bindkey '^[[4~' end-of-line



## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/sa/.dart-cli-completion/zsh-config.zsh ]] && . /home/sa/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]
