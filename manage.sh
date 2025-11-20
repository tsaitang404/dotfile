#!/bin/bash

# Dotfiles 管理工具

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Git 命令包装
dotfiles() {
    /usr/bin/git -C "$HOME" "$@"
}

show_help() {
    echo -e "${BLUE}Dotfiles 管理工具${NC}"
    echo ""
    echo "使用方法: $0 [命令] [参数]"
    echo ""
    echo "命令:"
    echo "  status       - 查看状态"
    echo "  add [文件]   - 添加文件"
    echo "  commit [消息] - 提交更改"
    echo "  push         - 推送到远程"
    echo "  pull         - 从远程拉取"
    echo "  sync         - 自动同步（add + commit + push）"
    echo "  backup       - 创建备份"
    echo "  list         - 列出跟踪文件"
    echo "  help         - 显示帮助"
}

ensure_ssh_agent() {
    local KEY="$HOME/.ssh/TT"

    # 检查私钥是否存在
    [ ! -f "$KEY" ] && { echo -e "${RED}错误: 私钥不存在: $KEY${NC}" >&2; return 1; }
    chmod 600 "$KEY" 2>/dev/null || true

    # 启动 agent
    [ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)" >/dev/null

    # 检查密钥是否已加载
    ssh-add -l >/dev/null 2>&1 && return 0

    # 交互式加载密钥
    if [ -t 0 ]; then
        echo -e "${YELLOW}加载私钥: $KEY${NC}"
        ssh-add "$KEY" || { echo -e "${RED}无法加载密钥${NC}" >&2; return 1; }
        return 0
    else
        echo -e "${RED}非交互式环境，请手动运行: ssh-add $KEY${NC}" >&2
        return 1
    fi
}

dotfiles_status() {
    echo -e "${BLUE}Dotfiles 状态:${NC}"
    dotfiles status
}

dotfiles_add() {
    [ -z "$1" ] && { echo -e "${RED}错误: 请指定文件${NC}" >&2; exit 1; }
    echo -e "${GREEN}添加: $1${NC}"
    dotfiles add "$1"
}

dotfiles_commit() {
    [ -z "$1" ] && { echo -e "${RED}错误: 请提供提交信息${NC}" >&2; exit 1; }
    echo -e "${GREEN}提交: $1${NC}"
    dotfiles commit -m "$1"
}

dotfiles_push() {
    # 确保 SSH 密钥已加载
    ensure_ssh_agent || return 1

    # 获取远程 URL
    local REMOTE_URL=$(dotfiles remote get-url origin 2>/dev/null)
    [ -z "$REMOTE_URL" ] && { echo -e "${RED}错误: 未找到远程仓库${NC}" >&2; return 1; }
    
    # 检测并修正 git:// 协议（只读，无法推送）
    if [[ "$REMOTE_URL" =~ ^git://([^/]+)/(.+)$ ]]; then
        local host="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        local new_url="git@${host}:${repo}"
        
        echo -e "${YELLOW}检测到只读协议: $REMOTE_URL${NC}"
        echo -e "${YELLOW}自动转换为 SSH 协议: $new_url${NC}"
        
        dotfiles remote set-url origin "$new_url"
        REMOTE_URL="$new_url"
    fi
    
    echo -e "${BLUE}远程: $REMOTE_URL${NC}"

    # 测试 SSH 连接（仅对 SSH URL）
    if [[ "$REMOTE_URL" =~ ^git@([^:]+): ]]; then
        local REMOTE_HOST="${BASH_REMATCH[1]}"
        echo -e "${YELLOW}测试连接: $REMOTE_HOST${NC}"
        ssh-keyscan -H "$REMOTE_HOST" >> ~/.ssh/known_hosts 2>/dev/null || true
        
        if ssh -o BatchMode=yes -o ConnectTimeout=10 -T "git@$REMOTE_HOST" 2>&1 | grep -qE "successfully authenticated|Hi "; then
            echo -e "${GREEN}连接成功${NC}"
        fi
    fi

    # 获取当前分支
    local CURRENT_BRANCH=$(dotfiles symbolic-ref --short HEAD 2>/dev/null || echo "master")
    local UPSTREAM=$(dotfiles rev-parse --abbrev-ref @{u} 2>/dev/null)
    
    echo -e "${GREEN}推送分支: $CURRENT_BRANCH${NC}"
    
    # 推送（首次推送自动设置上游）
    local PUSH_OUTPUT
    if [ -z "$UPSTREAM" ]; then
        echo -e "${YELLOW}设置上游: origin/$CURRENT_BRANCH${NC}"
        PUSH_OUTPUT=$(timeout 120 /usr/bin/git -C "$HOME" push -u origin "$CURRENT_BRANCH" 2>&1)
    else
        PUSH_OUTPUT=$(timeout 120 /usr/bin/git -C "$HOME" push 2>&1)
    fi
    
    local EXIT_CODE=$?
    
    case $EXIT_CODE in
        0)
            echo -e "${GREEN}推送成功${NC}"
            ;;
        124)
            echo -e "${RED}推送超时（120秒）${NC}"
            echo -e "${YELLOW}诊断: ssh -vT git@${REMOTE_HOST:-github.com}${NC}"
            ;;
        *)
            # 检测是否是 non-fast-forward 错误
            if echo "$PUSH_OUTPUT" | grep -q "rejected.*non-fast-forward"; then
                echo -e "${RED}推送被拒绝：本地分支落后于远程分支${NC}"
                echo ""
                echo -e "${YELLOW}解决方案：${NC}"
                echo -e "  1. 先拉取并合并远程更改：${BLUE}./manage.sh pull${NC}"
                echo -e "  2. 或手动合并：${BLUE}git -C ~ pull origin $CURRENT_BRANCH${NC}"
                echo -e "  3. 然后重新推送：${BLUE}./manage.sh push${NC}"
                echo ""
                read -p "是否立即拉取远程更改并重试推送? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    echo -e "${GREEN}拉取远程更改...${NC}"
                    if dotfiles pull origin "$CURRENT_BRANCH"; then
                        echo -e "${GREEN}拉取成功，重新推送...${NC}"
                        timeout 120 /usr/bin/git -C "$HOME" push
                        EXIT_CODE=$?
                        [ $EXIT_CODE -eq 0 ] && echo -e "${GREEN}推送成功${NC}" || echo -e "${RED}推送失败${NC}"
                    else
                        echo -e "${RED}拉取失败，请手动解决冲突${NC}"
                    fi
                fi
            else
                echo "$PUSH_OUTPUT"
                echo -e "${RED}推送失败（退出码: $EXIT_CODE）${NC}"
            fi
            ;;
    esac
    
    return $EXIT_CODE
}

dotfiles_pull() {
    ensure_ssh_agent || return 1
    echo -e "${GREEN}拉取更新...${NC}"
    dotfiles pull && echo -e "${GREEN}拉取成功${NC}" || echo -e "${RED}拉取失败${NC}"
}

dotfiles_sync() {
    echo -e "${BLUE}同步 dotfiles...${NC}"
    
    # 检查是否有更改
    if dotfiles diff --quiet && dotfiles diff --cached --quiet; then
        echo -e "${YELLOW}无更改${NC}"
        return 0
    fi
    
    dotfiles_status
    
    read -p "是否继续提交并推送? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        dotfiles add -u
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        dotfiles_commit "自动同步 - $timestamp"
        dotfiles_push
    else
        echo -e "${YELLOW}已取消${NC}"
    fi
}

dotfiles_backup() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_dir="$HOME/.dotfiles-backup-$timestamp"
    
    echo -e "${GREEN}备份至: $backup_dir${NC}"
    mkdir -p "$backup_dir"
    
    dotfiles ls-files | while IFS= read -r file; do
        if [ -f "$HOME/$file" ]; then
            local dir=$(dirname "$file")
            mkdir -p "$backup_dir/$dir"
            cp "$HOME/$file" "$backup_dir/$file"
        fi
    done
    
    echo -e "${GREEN}备份完成${NC}"
}

dotfiles_list() {
    echo -e "${BLUE}跟踪的文件:${NC}"
    dotfiles ls-files | sort
}

# 主程序
case "${1:-help}" in
    status) dotfiles_status ;;
    add) dotfiles_add "$2" ;;
    commit) dotfiles_commit "$2" ;;
    push) dotfiles_push ;;
    pull) dotfiles_pull ;;
    sync) dotfiles_sync ;;
    backup) dotfiles_backup ;;
    list) dotfiles_list ;;
    help|--help|-h) show_help ;;
    *)
        echo -e "${RED}未知命令: $1${NC}"
        show_help
        exit 1
        ;;
esac
