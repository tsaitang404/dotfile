#!/bin/bash

# 安装dotfiles的脚本

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查git是否安装
if ! command -v git &> /dev/null; then
    echo -e "${RED}Git未安装. 请先安装Git.${NC}"
    exit 1
fi

# 设置变量
DOTFILES_REPO="git@github.com:tsaitang404/dotfile.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"

# 显示欢迎信息
echo -e "${BLUE}=== 欢迎使用dotfiles安装脚本 ===${NC}"
echo -e "${YELLOW}这个脚本将会安装dotfiles到您的HOME目录${NC}"

# 克隆仓库(如果尚未克隆)
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${GREEN}正在克隆dotfiles仓库...${NC}"
    git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo -e "${YELLOW}dotfiles仓库已存在，跳过克隆.${NC}"
fi

# 创建alias
alias dotfiles="/usr/bin/git --git-dir=$DOTFILES_DIR --work-tree=$HOME"

# 备份现有文件
echo -e "${GREEN}备份可能会被覆盖的文件...${NC}"
mkdir -p "$BACKUP_DIR"
dotfiles checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' | xargs -I{} mv {} "$BACKUP_DIR/{}" 2>/dev/null || true

# 检出文件
echo -e "${GREEN}检出dotfiles...${NC}"
dotfiles checkout

# 隐藏未跟踪的文件
echo -e "${GREEN}配置git不显示未跟踪的文件...${NC}"
dotfiles config --local status.showUntrackedFiles no

# 添加alias到shell配置文件
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "alias dotfiles=" "$HOME/.bashrc"; then
        echo -e "${GREEN}添加dotfiles别名到.bashrc...${NC}"
        echo 'alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"' >> "$HOME/.bashrc"
    fi
fi

if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "alias dotfiles=" "$HOME/.zshrc"; then
        echo -e "${GREEN}添加dotfiles别名到.zshrc...${NC}"
        echo 'alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"' >> "$HOME/.zshrc"
    fi
fi

# 完成
echo -e "${GREEN}完成! dotfiles已安装.${NC}"
echo -e "${YELLOW}您可以使用 'dotfiles' 命令来管理您的dotfiles.${NC}"
echo -e "${YELLOW}如果您刚刚更新了shell配置文件，请重新加载它或重启终端以应用更改.${NC}"
