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

- .zshrc - Zsh配置文件
- .bashrc - Bash配置文件
- .vimrc - Vim配置文件
- .p10k.zsh - Powerlevel10k主题配置
- .gitconfig - Git全局配置
- .config/i3/config - i3窗口管理器配置
- .config/picom/picom.conf - Picom合成器配置
- .config/htop/htoprc - htop系统监控工具配置

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
