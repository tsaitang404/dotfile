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

- .zshrc
- .bashrc
- .vimrc
- .p10k.zsh
- .config/i3/config
- .config/picom/picom.conf
- .config/htop/htoprc
