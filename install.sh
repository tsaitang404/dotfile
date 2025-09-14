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
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo -e "${YELLOW}dotfiles仓库已存在，跳过克隆.${NC}"
fi

# 进入dotfiles目录
cd "$DOTFILES_DIR"

# 定义需要链接的文件列表
dotfiles=(
    ".bashrc"
    ".zshrc"
    ".vimrc"
    ".gitconfig"
    ".gitignore"
    ".tmux.conf"
    ".p10k.zsh"
    ".Xresources"
    ".bash_profile"
    ".fehbg"
    ".gtkrc-2.0"
    ".npmrc"
    ".xinitrc"
    ".xprofile"
)

# 定义需要链接的目录列表
dotdirs=(
    ".config"
    ".ssh"
)

# 备份现有文件和目录
echo -e "${GREEN}备份可能会被覆盖的文件...${NC}"
mkdir -p "$BACKUP_DIR"

for file in "${dotfiles[@]}"; do
    if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
        echo -e "${YELLOW}备份 $file${NC}"
        mv "$HOME/$file" "$BACKUP_DIR/"
    fi
done

for dir in "${dotdirs[@]}"; do
    if [ -d "$HOME/$dir" ] && [ ! -L "$HOME/$dir" ]; then
        echo -e "${YELLOW}备份 $dir${NC}"
        mv "$HOME/$dir" "$BACKUP_DIR/"
    fi
done

# 创建符号链接
echo -e "${GREEN}创建符号链接...${NC}"

for file in "${dotfiles[@]}"; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        echo -e "${GREEN}链接 $file${NC}"
        ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
    fi
done

for dir in "${dotdirs[@]}"; do
    if [ -d "$DOTFILES_DIR/$dir" ]; then
        echo -e "${GREEN}链接 $dir${NC}"
        ln -sf "$DOTFILES_DIR/$dir" "$HOME/$dir"
    fi
done

# 完成
echo -e "${GREEN}完成! dotfiles已安装.${NC}"
echo -e "${YELLOW}所有配置文件都已通过符号链接连接到仓库.${NC}"
echo -e "${YELLOW}您可以在 $DOTFILES_DIR 中管理您的dotfiles.${NC}"
echo ""
echo -e "${BLUE}=== 依赖检查 ===${NC}"

# 检查Zsh插件
echo -e "${GREEN}检查Zsh插件...${NC}"
if [ ! -d "$HOME/.config/zsh/plugins/zsh-autosuggestions" ]; then
    echo -e "${YELLOW}zsh-autosuggestions 插件缺失，正在安装...${NC}"
    mkdir -p "$HOME/.config/zsh/plugins"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.config/zsh/plugins/zsh-autosuggestions"
fi

if [ ! -d "$HOME/.config/zsh/plugins/zsh-syntax-highlighting" ]; then
    echo -e "${YELLOW}zsh-syntax-highlighting 插件缺失，正在安装...${NC}"
    mkdir -p "$HOME/.config/zsh/plugins"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.config/zsh/plugins/zsh-syntax-highlighting"
fi

# 检查Powerlevel10k主题
if [ ! -d "$HOME/.config/zsh/themes/powerlevel10k" ]; then
    echo -e "${YELLOW}Powerlevel10k 主题缺失，正在安装...${NC}"
    mkdir -p "$HOME/.config/zsh/themes"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.config/zsh/themes/powerlevel10k"
fi

echo -e "${GREEN}依赖检查完成!${NC}"
echo ""
echo -e "${BLUE}提示:${NC}"
echo -e "${YELLOW}- 如果Powerlevel10k主题显示异常，请运行: p10k configure${NC}"
echo -e "${YELLOW}- 确保安装了 Nerd Font 字体以获得最佳显示效果${NC}"
echo -e "${YELLOW}- 如果需要重新配置主题，运行: p10k configure${NC}"
echo -e "${YELLOW}- 要管理dotfiles，请进入 $DOTFILES_DIR 目录使用git命令或 ./manage.sh 脚本${NC}"