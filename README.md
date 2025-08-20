# Dotfiles

这是我的个人dotfiles仓库，使用bare repository管理方式。

## 安装

### 克隆仓库

```bash
git clone --bare git@github.com:tsaitang404/dotfile.git $HOME/.dotfiles
```

### 设置alias

```bash
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
```

### 检出文件

```bash
dotfiles checkout
```

如果checkout失败，请先备份冲突的文件：

```bash
mkdir -p .dotfiles-backup && \
dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .dotfiles-backup/{}
```

### 隐藏未跟踪的文件

```bash
dotfiles config --local status.showUntrackedFiles no
```

## 使用方法

### 添加新文件

```bash
dotfiles add .zshrc
dotfiles commit -m "Add .zshrc"
dotfiles push
```

### 查看状态

```bash
dotfiles status
```

### 更新文件

```bash
dotfiles pull
```

## 跟踪的文件

### 核心Shell配置
- `.zshrc` - Zsh配置文件
- `.bashrc` - Bash配置文件
- `.p10k.zsh` - Powerlevel10k主题配置

### 编辑器配置
- `.vimrc` - Vim配置文件

### Git配置
- `.gitconfig` - Git全局配置
- `.gitignore` - dotfiles忽略规则

### 窗口管理器配置
- `.config/i3/config` - i3窗口管理器配置
- `.config/i3/scripts/` - i3相关脚本
- `.config/picom/picom.conf` - Picom合成器配置

### 系统工具配置
- `.config/htop/htoprc` - htop系统监控工具配置

### Zsh增强功能
- `.config/zsh/themes/powerlevel10k/` - Powerlevel10k主题文件
- `.config/zsh/plugins/` - Zsh插件目录
  - `zsh-autosuggestions` - 命令自动建议插件
  - `zsh-syntax-highlighting` - 语法高亮插件

### 管理工具
- `README.md` - 本说明文档
- `install.sh` - 自动安装脚本
- `manage.sh` - 便捷管理脚本
- `cleanup.sh` - 仓库清理脚本

## 便捷管理工具

使用 `manage.sh` 脚本可以更方便地管理dotfiles：

```bash
# 查看帮助
./manage.sh help

# 查看状态
./manage.sh status

# 添加文件
./manage.sh add .bashrc

# 提交更改
./manage.sh commit "更新bash配置"

# 推送到远程
./manage.sh push

# 一键同步（添加、提交、推送）
./manage.sh sync

# 创建备份
./manage.sh backup

# 列出所有跟踪的文件
./manage.sh list
```

## 自动化配置

该仓库已配置了以下自动化功能：

1. **SSH代理自动启动**: 在.bashrc和.zshrc中配置了SSH代理自动启动
2. **dotfiles别名**: 自动设置dotfiles命令别名
3. **智能忽略**: 使用否定模式的.gitignore，只跟踪指定文件

## 依赖安装

### Zsh 主题和插件

本仓库包含了完整的Zsh配置，包括主题和插件。在新机器上安装时：

#### Powerlevel10k 主题
如果主题文件缺失，可以通过以下方式安装：

```bash
# 方式1: 通过 Oh My Zsh (如果使用 Oh My Zsh)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# 方式2: 直接克隆到配置目录
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.config/zsh/themes/powerlevel10k
```

#### Zsh 插件
本仓库跟踪以下插件，如果缺失可以手动安装：

```bash
# zsh-autosuggestions (命令自动建议)
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.config/zsh/plugins/zsh-autosuggestions

# zsh-syntax-highlighting (语法高亮)
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh/plugins/zsh-syntax-highlighting
```

### 系统依赖

一些配置可能需要额外的系统包：

```bash
# Arch Linux
sudo pacman -S i3-wm picom htop vim git

# Ubuntu/Debian
sudo apt install i3 picom htop vim git

# Fedora
sudo dnf install i3 picom htop vim git
```

## 故障排除

### 常见问题

1. **Powerlevel10k 主题不显示**：
   - 确保安装了 Nerd Font 字体
   - 运行 `p10k configure` 重新配置主题

2. **Zsh 插件不工作**：
   - 检查插件文件是否存在于 `~/.config/zsh/plugins/` 目录
   - 确保在 `.zshrc` 中正确 source 了插件文件

3. **SSH 密钥问题**：
   - 确保 SSH 密钥已添加到 GitHub
   - 检查 SSH 代理是否运行：`ssh-add -l`

### 重新配置

如果需要重新配置 Powerlevel10k：
```bash
p10k configure
```
