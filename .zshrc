# 设置默认的 shell 提示符
# %n - 用户名, %m - 主机名, %~ - 当前目录
# 替换掉 export PS1 为更推荐的 PROMPT（避免导出无用变量）
{ 
# 原来: export PS1='%n@%m:%~ %# '
PROMPT='%n@%m:%~ %# '
}

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

# 更稳健的 dart completion 加载（使用 $HOME，避免硬编码路径）
{
# 原来: [[ -f /home/sa/.dart-cli-completion/zsh-config.zsh ]] && . /home/sa/.dart-cli-completion/zsh-config.zsh || true
if [ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]; then
    source "$HOME/.dart-cli-completion/zsh-config.zsh"
fi
}

# nodejs multi version manage — 更安全的检测 nvm 的常见位置
{
# 原来: source /usr/share/nvm/init-nvm.sh
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    # nvm installed in user's home
    . "$HOME/.nvm/nvm.sh"
elif [ -s /usr/share/nvm/init-nvm.sh ]; then
    # distro-provided location
    . /usr/share/nvm/init-nvm.sh
fi
}

# pyenv plugins init — 仅在存在 pyenv 时执行
{
# 原来直接 export/eval 无检测
if [ -d "$HOME/.pyenv" ] || [ -n "$PYENV_ROOT" ]; then
    export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
    export PATH="$PYENV_ROOT/bin:$PATH"
    if command -v pyenv >/dev/null 2>&1; then
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
        # virtualenv init (如果已安装)
        if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
            eval "$(pyenv virtualenv-init -)"
        fi
    fi
fi
}

# Powerlevel10k：按更多常见位置检测并加载 theme，然后加载用户的 p10k 配置
{
P10K_THEME_PATHS=(
    "$HOME/.config/powerlevel10k/powerlevel10k.zsh-theme"
    "$HOME/.powerlevel10k/powerlevel10k.zsh-theme"
    "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
    "$HOME/.oh-my-zsh/custom/plugins/powerlevel10k/powerlevel10k.zsh-theme"
    "$HOME/.local/share/powerlevel10k/powerlevel10k.zsh-theme"
    "/usr/share/powerlevel10k/powerlevel10k.zsh-theme"
    "/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme"
    "/usr/share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme"
    "/usr/share/oh-my-zsh/themes/powerlevel10k/powerlevel10k.zsh-theme"
)

P10K_LOADED=false
for _p in "${P10K_THEME_PATHS[@]}"; do
    if [ -f "$_p" ]; then
        source "$_p"
        P10K_LOADED=true
        break
    fi
done

# 如果使用 oh-my-zsh 而 theme 未被直接找到，尝试设置 ZSH_THEME（某些安装方式依赖此变量）
if [ "$P10K_LOADED" != "true" ] && [ -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
    # 仅当尚未设置为 powerlevel10k 时尝试
    if [ "${ZSH_THEME:-}" != "powerlevel10k/powerlevel10k" ] && [ "${ZSH_THEME:-}" != "powerlevel10k" ]; then
        ZSH_THEME="powerlevel10k/powerlevel10k"
    fi
fi

# 如果用户有自定义的 p10k 配置文件，加载它（必须在 theme 之后）
if [ -f "$HOME/.p10k.zsh" ]; then
    source "$HOME/.p10k.zsh"
fi
}

# 历史记录：不要在会话间共享历史，但所有终端都写入历史文件
{
# 原来:
# HISTFILE=~/.histfile
# HISTSIZE=10000
# SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# 取消会话间内存共享（避免即时在其它终端可见）
unsetopt SHARE_HISTORY

# 将命令追加到历史文件：
# INC_APPEND_HISTORY - 每条命令立即写入历史文件
# APPEND_HISTORY - 退出时追加，作为补充保障（防止覆盖）
setopt INC_APPEND_HISTORY
setopt APPEND_HISTORY

# 过期重复项优先移除
setopt HIST_EXPIRE_DUPS_FIRST
}

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

# 案件绑定 
# 绑定 Home 键跳转到行首
bindkey '^[[H' beginning-of-line
bindkey '^[[1~' beginning-of-line
bindkey '\e[1~' beginning-of-line

# 绑定 End 键跳转到行尾
bindkey '^[[F' end-of-line
bindkey '^[[4~' end-of-line
bindkey '\e[4~' end-of-line

# dotfiles管理别名
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
