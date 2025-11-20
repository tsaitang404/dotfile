#!/bin/bash

# 安装dotfiles的脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 错误处理：遇到错误立即退出
set -e
trap 'echo -e "${RED}安装失败，请检查错误信息${NC}"' ERR

# 检查依赖
check_dependencies() {
    local missing=()
    for cmd in git curl; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}缺少依赖: ${missing[*]}${NC}"
        echo -e "${YELLOW}请先安装: sudo pacman -S ${missing[*]}${NC}"
        exit 1
    fi
}

# 设置变量
DOTFILES_REPO="git@github.com:tsaitang404/dotfile.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d_%H%M%S)"

# 显示欢迎信息
echo -e "${BLUE}=== Dotfiles 安装脚本 ===${NC}"
echo -e "${YELLOW}仓库: $DOTFILES_REPO${NC}"
echo -e "${YELLOW}目标: $DOTFILES_DIR${NC}\n"

# 检查依赖
check_dependencies

# 克隆或更新仓库
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${GREEN}克隆仓库...${NC}"
    # 改进：避免 grep 失败导致 set -e 退出
    if timeout 5 ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" || true; then
        : # SSH 可用，保持原 URL
    else
        echo -e "${YELLOW}SSH 认证失败，尝试 HTTPS 克隆${NC}"
        DOTFILES_REPO="https://github.com/tsaitang404/dotfile.git"
    fi
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || {
        echo -e "${RED}克隆失败，请检查网络和 SSH 密钥${NC}"
        exit 1
    }
else
    echo -e "${YELLOW}仓库已存在${NC}"
    # 修复：添加 -r 选项和默认值说明
    read -p "是否更新仓库? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        (cd "$DOTFILES_DIR" && git pull) || echo -e "${YELLOW}更新失败，继续使用现有版本${NC}"
    fi
fi

cd "$DOTFILES_DIR" || exit 1

# 定义配置文件
echo -e "${GREEN}检测配置文件...${NC}"
# 改进：添加错误处理，避免空数组
mapfile -t dotfiles < <(git ls-files 2>/dev/null | grep -E '^\.[^/]+$' | grep -vE '^\.(git|DS_Store|gitignore|gitmodules)$' || true)
mapfile -t dotdirs < <(git ls-files 2>/dev/null | cut -d/ -f1 | grep '^\.' | sort -u | grep -vE '^\.(git|DS_Store)$' || true)

# 改进：检查是否有文件
if [ ${#dotfiles[@]} -eq 0 ] && [ ${#dotdirs[@]} -eq 0 ]; then
    echo -e "${RED}未检测到配置文件，请检查仓库结构${NC}"
    exit 1
fi

echo -e "${BLUE}发现文件: ${#dotfiles[@]} 个${NC}"
echo -e "${BLUE}发现目录: ${#dotdirs[@]} 个${NC}\n"

# 备份现有文件
backup_needed=false
for file in "${dotfiles[@]}"; do
    [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ] && backup_needed=true && break
done
for dir in "${dotdirs[@]}"; do
    [ -e "$HOME/$dir" ] && [ ! -L "$HOME/$dir" ] && backup_needed=true && break
done

if [ "$backup_needed" = true ]; then
    echo -e "${YELLOW}备份现有文件到: $BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
    
    for file in "${dotfiles[@]}"; do
        if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            echo -e "  备份 $file"
            cp -a "$HOME/$file" "$BACKUP_DIR/"
        fi
    done
    
    for dir in "${dotdirs[@]}"; do
        if [ -e "$HOME/$dir" ] && [ ! -L "$HOME/$dir" ]; then
            echo -e "  备份 $dir"
            cp -a "$HOME/$dir" "$BACKUP_DIR/"
        fi
    done
fi

# 创建符号链接
echo -e "\n${GREEN}创建符号链接...${NC}"
# 修复：local 只能在函数内使用，脚本主体应使用普通变量
linked_count=0

for file in "${dotfiles[@]}"; do
    if [ -e "$DOTFILES_DIR/$file" ]; then
        if [ -L "$HOME/$file" ] || [ -f "$HOME/$file" ]; then
            rm -f "$HOME/$file"
        elif [ -d "$HOME/$file" ]; then
            echo -e "${RED}警告: $file 是目录，跳过${NC}"
            continue
        fi
        ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
        echo -e "  链接 $file"
        ((linked_count++))
    fi
done

for dir in "${dotdirs[@]}"; do
    if [ -e "$DOTFILES_DIR/$dir" ]; then
        if [ -e "$HOME/$dir" ] && [ ! -L "$HOME/$dir" ]; then
            read -p "  $dir 已存在且未备份，是否覆盖? (y/N): " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && continue
        fi
        rm -rf "$HOME/$dir"
        ln -sf "$DOTFILES_DIR/$dir" "$HOME/$dir"
        echo -e "  链接 $dir"
        ((linked_count++))
    fi
done

echo -e "${GREEN}共创建 $linked_count 个符号链接${NC}"

# 安装依赖（优化：并行克隆）
install_zsh_plugins() {
    local plugins_dir="$HOME/.config/zsh/plugins"
    local themes_dir="$HOME/.config/zsh/themes"
    
    mkdir -p "$plugins_dir" "$themes_dir"
    
    declare -A repos=(
        ["$plugins_dir/zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
        ["$plugins_dir/zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
        ["$themes_dir/powerlevel10k"]="https://github.com/romkatv/powerlevel10k"
    )
    
    echo -e "\n${GREEN}安装 Zsh 插件和主题...${NC}"
    # 修复：记录并发进程 PID，检查克隆是否成功
    local pids=()
    for dir in "${!repos[@]}"; do
        if [ ! -d "$dir" ]; then
            echo -e "  安装 $(basename "$dir")"
            git clone --depth=1 "${repos[$dir]}" "$dir" &>/dev/null &
            pids+=($!)
        fi
    done
    
    # 等待所有克隆完成并检查状态
    local failed=0
    for pid in "${pids[@]}"; do
        wait "$pid" || ((failed++))
    done
    
    [ $failed -gt 0 ] && echo -e "${YELLOW}部分插件安装失败，可手动重试${NC}"
}

install_zsh_plugins

# 链接 manage.sh 到 HOME 目录
echo -e "\n${GREEN}设置管理脚本...${NC}"
if [ -f "$DOTFILES_DIR/manage.sh" ]; then
    ln -sf "$DOTFILES_DIR/manage.sh" "$HOME/manage.sh"
    chmod +x "$HOME/manage.sh"
    echo -e "${GREEN}✓ manage.sh 已链接到 ~/manage.sh${NC}"
fi

# 完成
echo -e "\n${GREEN}✓ 安装完成!${NC}"
echo -e "${BLUE}提示:${NC}"
echo -e "  - 重启终端或运行: ${YELLOW}source ~/.zshrc${NC}"
echo -e "  - 配置 p10k: ${YELLOW}p10k configure${NC}"
echo -e "  - 管理 dotfiles: ${YELLOW}~/manage.sh${NC}"
[ "$backup_needed" = true ] && echo -e "  - 备份位于: ${YELLOW}$BACKUP_DIR${NC}"
echo -e "  - 卸载: ${YELLOW}rm -rf $DOTFILES_DIR ~/manage.sh && 恢复备份${NC}"