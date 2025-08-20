#!/bin/bash

# Dotfiles 管理工具
# 使用方法: ./manage.sh [命令] [参数]

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 设置dotfiles命令函数
dotfiles() {
    /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

show_help() {
    echo -e "${BLUE}Dotfiles 管理工具${NC}"
    echo ""
    echo "使用方法: $0 [命令] [参数]"
    echo ""
    echo "命令:"
    echo "  status       - 查看状态"
    echo "  add [文件]   - 添加文件到版本管理"
    echo "  commit [消息] - 提交更改"
    echo "  push         - 推送到远程仓库"
    echo "  pull         - 从远程仓库拉取"
    echo "  sync         - 添加所有更改、提交并推送"
    echo "  backup       - 创建当前配置的备份"
    echo "  list         - 列出所有跟踪的文件"
    echo "  help         - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 add .bashrc"
    echo "  $0 commit \"更新bash配置\""
    echo "  $0 sync"
}

ensure_ssh_agent() {
    if [ -z "$SSH_AUTH_SOCK" ]; then
        echo -e "${YELLOW}启动SSH代理...${NC}"
        eval "$(ssh-agent -s)" > /dev/null
        ssh-add ~/.ssh/TT 2>/dev/null
    fi
}

dotfiles_status() {
    echo -e "${BLUE}Dotfiles 状态:${NC}"
    dotfiles status
}

dotfiles_add() {
    if [ -z "$1" ]; then
        echo -e "${RED}错误: 请指定要添加的文件${NC}"
        echo "使用方法: $0 add <文件名>"
        exit 1
    fi
    
    echo -e "${GREEN}添加文件: $1${NC}"
    dotfiles add "$1"
    echo -e "${GREEN}文件已添加到暂存区${NC}"
}

dotfiles_commit() {
    if [ -z "$1" ]; then
        echo -e "${RED}错误: 请提供提交信息${NC}"
        echo "使用方法: $0 commit \"提交信息\""
        exit 1
    fi
    
    echo -e "${GREEN}提交更改: $1${NC}"
    dotfiles commit -m "$1"
}

dotfiles_push() {
    ensure_ssh_agent
    echo -e "${GREEN}推送到远程仓库...${NC}"
    dotfiles push origin master
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}推送成功!${NC}"
    else
        echo -e "${RED}推送失败，请检查网络连接和SSH密钥${NC}"
    fi
}

dotfiles_pull() {
    ensure_ssh_agent
    echo -e "${GREEN}从远程仓库拉取...${NC}"
    dotfiles pull origin master
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}拉取成功!${NC}"
    else
        echo -e "${RED}拉取失败，请检查网络连接和SSH密钥${NC}"
    fi
}

dotfiles_sync() {
    echo -e "${BLUE}同步dotfiles...${NC}"
    
    # 检查是否有更改
    if dotfiles diff --quiet && dotfiles diff --cached --quiet; then
        echo -e "${YELLOW}没有检测到更改${NC}"
        return
    fi
    
    # 显示状态
    dotfiles_status
    
    echo -e "${YELLOW}是否继续提交并推送? (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        # 添加所有已修改的文件
        dotfiles add -u
        
        # 生成提交信息
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        commit_msg="自动同步配置文件 - $timestamp"
        
        dotfiles_commit "$commit_msg"
        dotfiles_push
    else
        echo -e "${YELLOW}同步已取消${NC}"
    fi
}

dotfiles_backup() {
    timestamp=$(date '+%Y%m%d_%H%M%S')
    backup_dir="$HOME/.dotfiles-backup-$timestamp"
    
    echo -e "${GREEN}创建备份到: $backup_dir${NC}"
    mkdir -p "$backup_dir"
    
    # 备份跟踪的文件
    dotfiles ls-files | while read -r file; do
        if [ -f "$HOME/$file" ]; then
            mkdir -p "$backup_dir/$(dirname "$file")"
            cp "$HOME/$file" "$backup_dir/$file"
        fi
    done
    
    echo -e "${GREEN}备份完成!${NC}"
}

dotfiles_list() {
    echo -e "${BLUE}跟踪的文件:${NC}"
    dotfiles ls-files | sort
}

# 主程序
case "$1" in
    status)
        dotfiles_status
        ;;
    add)
        dotfiles_add "$2"
        ;;
    commit)
        dotfiles_commit "$2"
        ;;
    push)
        dotfiles_push
        ;;
    pull)
        dotfiles_pull
        ;;
    sync)
        dotfiles_sync
        ;;
    backup)
        dotfiles_backup
        ;;
    list)
        dotfiles_list
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        echo -e "${RED}未知命令: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
