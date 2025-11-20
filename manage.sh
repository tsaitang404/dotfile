#!/bin/bash

# Dotfiles 管理工具

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 修复：应该操作 ~/.dotfiles 目录，而非 HOME
DOTFILES_DIR="$HOME/.dotfiles"

# 检查并初始化仓库
check_repo() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo -e "${RED}错误: $DOTFILES_DIR 不存在${NC}" >&2
        echo -e "${YELLOW}请先运行安装脚本${NC}" >&2
        exit 1
    fi
    
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        echo -e "${RED}错误: $DOTFILES_DIR 不是 Git 仓库${NC}" >&2
        echo -e "${YELLOW}请先运行安装脚本或手动克隆仓库${NC}" >&2
        exit 1
    fi
}

dotfiles() {
    check_repo
    /usr/bin/git -C "$DOTFILES_DIR" "$@"
}

show_help() {
    echo -e "${BLUE}Dotfiles 管理工具${NC}\n"
    echo "使用方法: $0 [命令] [参数]\n"
    echo "命令:"
    echo "  status       - 查看状态"
    echo "  add [文件]   - 添加文件"
    echo "  commit [消息] - 提交更改"
    echo "  push         - 推送到远程"
    echo "  pull         - 从远程拉取"
    echo "  sync         - 自动同步"
    echo "  backup       - 创建备份"
    echo "  list         - 列出跟踪文件"
}

ensure_ssh_agent() {
    # 尝试常见的 SSH 密钥位置
    local KEYS=(
        "$HOME/.ssh/ssh_key"      # .ssh/config 中指定的密钥
        "$HOME/.ssh/id_ed25519"   # 现代默认密钥
        "$HOME/.ssh/id_rsa"       # 传统默认密钥
        "$HOME/.ssh/TT"           # 自定义密钥
    )
    
    # 检查是否已经有密钥加载
    [ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)" >/dev/null
    ssh-add -l >/dev/null 2>&1 && return 0
    
    # 尝试找到并加载密钥
    local KEY_FOUND=""
    for key in "${KEYS[@]}"; do
        if [ -f "$key" ]; then
            KEY_FOUND="$key"
            chmod 600 "$key" 2>/dev/null
            break
        fi
    done
    
    [ -z "$KEY_FOUND" ] && { echo -e "${RED}错误: 未找到 SSH 私钥${NC}" >&2; return 1; }
    [ -t 0 ] || { echo -e "${RED}非交互式环境，请手动运行: ssh-add $KEY_FOUND${NC}" >&2; return 1; }
    echo -e "${YELLOW}加载私钥: $KEY_FOUND${NC}"
    ssh-add "$KEY_FOUND"
}

dotfiles_add() {
    [ -z "$1" ] && { echo -e "${RED}请指定文件${NC}" >&2; exit 1; }
    local file="$1"
    
    # 修复：检查文件存在性（在 HOME 或 .dotfiles 中）
    if [ -e "$HOME/$file" ]; then
        # 文件在 HOME 中，需要复制到 .dotfiles
        echo -e "${GREEN}复制到仓库: $file${NC}"
        mkdir -p "$DOTFILES_DIR/$(dirname "$file")"
        cp -a "$HOME/$file" "$DOTFILES_DIR/$file"
        
        # 创建符号链接
        rm -f "$HOME/$file"
        ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
    elif [ -e "$DOTFILES_DIR/$file" ]; then
        # 文件已在 .dotfiles 中
        echo -e "${YELLOW}文件已在仓库中: $file${NC}"
    else
        echo -e "${RED}文件不存在: $file${NC}" >&2
        exit 1
    fi
    
    echo -e "${GREEN}添加到 Git: $file${NC}"
    dotfiles add "$file"
}

dotfiles_push() {
    ensure_ssh_agent || return 1
    
    local REMOTE_URL=$(dotfiles remote get-url origin 2>/dev/null)
    [ -z "$REMOTE_URL" ] && { echo -e "${RED}未找到远程仓库${NC}" >&2; return 1; }
    
    # 修正 git:// 协议
    if [[ "$REMOTE_URL" =~ ^git://([^/]+)/(.+)$ ]]; then
        local new_url="git@${BASH_REMATCH[1]}:${BASH_REMATCH[2]}"
        echo -e "${YELLOW}转换为 SSH: $new_url${NC}"
        dotfiles remote set-url origin "$new_url"
        REMOTE_URL="$new_url"
    fi
    
    echo -e "${BLUE}远程: $REMOTE_URL${NC}"
    
    # 测试连接
    if [[ "$REMOTE_URL" =~ ^git@([^:]+): ]]; then
        local host="${BASH_REMATCH[1]}"
        grep -q "^[^#].*$host" ~/.ssh/known_hosts 2>/dev/null || \
            ssh-keyscan -H "$host" >> ~/.ssh/known_hosts 2>/dev/null
    fi
    
    local BRANCH=$(dotfiles symbolic-ref --short HEAD 2>/dev/null || echo "master")
    local UPSTREAM=$(dotfiles rev-parse --abbrev-ref @{u} 2>/dev/null)
    
    echo -e "${GREEN}推送: $BRANCH${NC}"
    
    local PUSH_OUTPUT
    if [ -z "$UPSTREAM" ]; then
        # 修复：使用 -C "$DOTFILES_DIR" 而非 "$HOME"
        PUSH_OUTPUT=$(timeout 120 /usr/bin/git -C "$DOTFILES_DIR" push -u origin "$BRANCH" 2>&1)
    else
        PUSH_OUTPUT=$(timeout 120 /usr/bin/git -C "$DOTFILES_DIR" push 2>&1)
    fi
    
    local CODE=$?
    
    if [ $CODE -eq 0 ]; then
        echo -e "${GREEN}推送成功${NC}"
    elif [ $CODE -eq 124 ]; then
        echo -e "${RED}推送超时${NC}"
    elif echo "$PUSH_OUTPUT" | grep -q "non-fast-forward"; then
        echo -e "${RED}本地落后于远程${NC}"
        read -p "立即拉取并重试? (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && dotfiles pull origin "$BRANCH" && /usr/bin/git -C "$DOTFILES_DIR" push
    else
        echo "$PUSH_OUTPUT"
        echo -e "${RED}推送失败${NC}"
    fi
    
    return $CODE
}

dotfiles_pull() {
    ensure_ssh_agent || return 1
    
    # 检查未解决冲突
    if dotfiles ls-files -u | grep -q .; then
        echo -e "${RED}存在未解决冲突${NC}"
        dotfiles ls-files -u | cut -f2 | sort -u | sed 's/^/  /'
        echo -e "\n${YELLOW}解决步骤:${NC}"
        echo "  1. 编辑冲突文件"
        echo "  2. ./manage.sh add <文件>"
        echo "  3. ./manage.sh commit \"解决冲突\""
        return 1
    fi
    
    echo -e "${GREEN}拉取更新${NC}"
    dotfiles pull && echo -e "${GREEN}成功${NC}" || echo -e "${RED}失败${NC}"
}

dotfiles_sync() {
    if dotfiles diff --quiet && dotfiles diff --cached --quiet; then
        local untracked=$(dotfiles ls-files --others --exclude-standard)
        if [ -n "$untracked" ]; then
            echo -e "${YELLOW}存在未跟踪文件：${NC}"
            echo "$untracked" | sed 's/^/  /'
        else
            echo -e "${YELLOW}无更改${NC}"
        fi
        return
    fi
    dotfiles status
    read -p "提交并推送? (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || { echo -e "${YELLOW}已取消${NC}"; return; }
    dotfiles add -u
    dotfiles commit -m "自动同步 - $(date '+%Y-%m-%d %H:%M:%S')"
    dotfiles_push
}

# 主程序
case "${1:-help}" in
    status) dotfiles status ;;
    add) dotfiles_add "$2" ;;
    commit) [ -z "$2" ] && { echo -e "${RED}请提供提交信息${NC}" >&2; exit 1; }; dotfiles commit -m "$2" ;;
    push) dotfiles_push ;;
    pull) dotfiles_pull ;;
    sync) dotfiles_sync ;;
    backup)
        dir="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$dir"
        # 修复：从 .dotfiles 目录读取文件列表
        dotfiles ls-files | while read -r f; do
            [ -f "$DOTFILES_DIR/$f" ] && { mkdir -p "$dir/$(dirname "$f")"; cp "$DOTFILES_DIR/$f" "$dir/$f"; }
        done
        echo -e "${GREEN}备份至: $dir${NC}"
        ;;
    list) dotfiles ls-files | sort ;;
    help|--help|-h) show_help ;;
    *) echo -e "${RED}未知命令: $1${NC}"; show_help; exit 1 ;;
esac
