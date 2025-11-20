# Dotfiles

我的个人 dotfiles 仓库，使用 Git 直接在 `$HOME` 目录管理配置文件。

## 特性

✨ **智能安装脚本**
- 自动检测 SSH/HTTPS 连接
- 智能备份现有配置
- 并行安装 Zsh 插件和主题
- 完善的错误处理

🛠️ **便捷管理工具**
- 一键同步配置文件
- 自动处理 SSH 密钥
- 冲突检测和解决
- 非阻塞式推送

## 快速开始

### 一键安装

使用 curl（推荐）:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tsaitang404/dotfile/master/install.sh)"
```

或使用 wget:
```bash
bash -c "$(wget -qO- https://raw.githubusercontent.com/tsaitang404/dotfile/master/install.sh)"
```

安装脚本会自动：
- ✅ 检测并提示安装依赖（git, curl）
- ✅ 克隆仓库到 `~/.dotfiles`
- ✅ 备份现有配置文件（带时间戳）
- ✅ 创建符号链接
- ✅ 安装 Zsh 插件和 Powerlevel10k 主题
- ✅ SSH 失败时自动切换 HTTPS

### 手动安装（可选）

如果无法使用一键安装，可以手动下载：

```bash
# 下载安装脚本
curl -fsSL https://raw.githubusercontent.com/tsaitang404/dotfile/master/install.sh -o /tmp/install.sh

# 运行安装
bash /tmp/install.sh
```

### 首次配置

```bash
# 重启终端或刷新配置
source ~/.zshrc

# 配置 Powerlevel10k 主题（可选）
p10k configure
```

## 管理工具

### 基本用法

```bash
# 查看帮助
~/manage.sh help

# 查看状态
~/manage.sh status

# 添加文件
~/manage.sh add .vimrc

# 提交更改
~/manage.sh commit "更新 Vim 配置"

# 推送到远程
~/manage.sh push

# 拉取更新
~/manage.sh pull
```

### 高级功能

```bash
# 一键同步（自动 add + commit + push）
~/.dotfiles/manage.sh sync

# 创建备份（带时间戳）
~/.dotfiles/manage.sh backup

# 列出所有跟踪的文件
~/.dotfiles/manage.sh list
```

### 智能特性

**自动处理 SSH 密钥**
- 首次推送时自动加载 SSH 密钥
- 支持加密密钥的口令提示
- 非交互环境友好提示

**冲突处理**
- 推送前自动检测冲突
- 提供交互式合并选项
- 清晰的冲突解决指引

**协议自动切换**
- 自动检测并修正 `git://` 协议
- 推送失败时提供重试选项

## 跟踪的文件

### Shell 配置
- `.zshrc` - Zsh 配置（含插件加载）
- `.bashrc` - Bash 配置
- `.bash_profile` - Bash 登录配置
- `.p10k.zsh` - Powerlevel10k 主题

### 开发工具
- `.vimrc` - Vim 编辑器
- `.gitconfig` - Git 全局配置
- `.gitignore_global` - 全局 gitignore
- `.npmrc` - Node.js 包管理器

### 窗口管理器
- `.config/i3/` - i3wm 配置和脚本
- `.config/picom/` - 窗口合成器
- `.xinitrc` - X11 启动
- `.xprofile` - X11 配置

### 系统工具
- `.config/htop/` - 系统监控
- `.tmux.conf` - 终端复用器
- `.fehbg` - 壁纸设置

### Zsh 增强
- `.config/zsh/plugins/zsh-autosuggestions` - 自动建议
- `.config/zsh/plugins/zsh-syntax-highlighting` - 语法高亮
- `.config/zsh/themes/powerlevel10k` - 主题

## 工作原理

### 仓库结构

```
~/.dotfiles/          # 仓库目录（Git 仓库）
├── .zshrc           # 配置文件
├── .config/         # 应用配置目录
├── manage.sh        # 管理脚本
├── install.sh       # 安装脚本
└── README.md        # 本文档

~/                   # HOME 目录
├── .zshrc -> ~/.dotfiles/.zshrc  # 符号链接
├── .config -> ~/.dotfiles/.config
└── ...
```

### Git 配置

<!-- 修复：本仓库使用符号链接方式，Git 仓库在 ~/.dotfiles，而非直接在 $HOME -->
本仓库使用符号链接管理，Git 仓库位于 `~/.dotfiles`：

```bash
# 查看配置
cd ~/.dotfiles && git config --local --list

# 查看远程仓库
cd ~/.dotfiles && git remote -v

# 手动初始化（安装脚本已自动完成）
cd ~/.dotfiles
git remote add origin git@github.com:tsaitang404/dotfile.git
```

## 依赖项

### 必需
- `git` - 版本控制
- `curl` - 下载工具
- `zsh` - Z Shell

### 可选
- `vim` - 文本编辑器
- `i3` - 窗口管理器
- `picom` - 窗口合成器
- `htop` - 系统监控
- `tmux` - 终端复用器

### 字体
- Nerd Font（任意一款）- Powerlevel10k 图标显示

推荐字体：
- `ttf-meslo-nerd-font-powerlevel10k`（Arch Linux）
- [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts)（手动安装）

## 常见问题

### 安装相关

**Q: 一键安装失败，提示无法连接？**
```bash
# 方案 1: 检查网络连接
ping raw.githubusercontent.com

# 方案 2: 使用镜像（中国大陆用户）
# 修复：镜像 URL 格式
bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/tsaitang404/dotfile/master/install.sh)"

# 或使用 jsdelivr CDN
bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/tsaitang404/dotfile@master/install.sh)"

# 方案 3: 手动下载后安装（见上方"手动安装"）
```

**Q: 安装时提示 SSH 认证失败？**
```bash
# 方案 1: 脚本会自动切换到 HTTPS
# 方案 2: 手动配置 SSH 密钥
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub  # 添加到 GitHub
```

**Q: 如何更新已安装的 dotfiles？**
```bash
cd ~/.dotfiles && git pull
# 或使用管理脚本
~/manage.sh pull
```

### 使用相关

**Q: Powerlevel10k 显示乱码？**
```bash
# 1. 安装 Nerd Font
# Arch Linux:
sudo pacman -S ttf-meslo-nerd-font-powerlevel10k

# 2. 在终端设置中选择该字体
# 3. 重新配置主题
p10k configure
```

**Q: Zsh 插件不生效？**
```bash
# 检查插件是否存在
ls ~/.config/zsh/plugins/

# 重新运行安装脚本的插件部分
cd ~/.dotfiles
./install.sh  # 选择 N（不更新仓库）
```

**Q: 推送时卡住？**
```bash
# 检查 SSH 密钥
ssh -T git@github.com

# 手动加载密钥
ssh-add ~/.ssh/id_ed25519

# 或修改为 HTTPS
cd ~/.dotfiles && git remote set-url origin https://github.com/tsaitang404/dotfile.git
```

**Q: 如何解决合并冲突？**
```bash
# 1. 查看冲突文件
cd ~/.dotfiles && git status

# 2. 编辑冲突文件（搜索 <<<<<<<）
vim ~/.dotfiles/.zshrc

# 3. 标记为已解决
~/manage.sh add .zshrc

# 4. 完成合并
~/manage.sh commit "解决冲突"
```

### 卸载

```bash
# 1. 删除符号链接
find ~ -maxdepth 1 -type l | while read link; do
    [[ "$(readlink "$link")" == "$HOME/.dotfiles"* ]] && rm "$link"
done
[[ -L ~/.config ]] && rm ~/.config

# 2. 删除仓库和管理脚本
rm -rf ~/.dotfiles ~/manage.sh

# 3. 恢复备份（如果需要）
BACKUP=$(ls -dt ~/.dotfiles-backup-* 2>/dev/null | head -1)
if [ -n "$BACKUP" ]; then
    echo "恢复备份: $BACKUP"
    cp -r "$BACKUP"/.??* ~/ 2>/dev/null
    cp -r "$BACKUP"/.config ~/ 2>/dev/null
fi
```

## 高级技巧

### 添加新机器

```bash
# 在新机器上直接运行一键安装命令
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tsaitang404/dotfile/master/install.sh)"

# 如果有本地修改需要保留
cd ~/.dotfiles
git stash
git pull
git stash pop
```

### 管理敏感信息

```bash
# .gitignore 中排除敏感文件
echo ".ssh/id_*" >> ~/.gitignore
echo ".gnupg/" >> ~/.gitignore

# 或使用加密工具
# git-crypt, BlackBox, SOPS 等
```

### 自动化同步

```bash
# 添加到 crontab（每天同步）
0 9 * * * cd ~/.dotfiles && ./manage.sh sync

# 或使用 systemd timer
# 创建 ~/.config/systemd/user/dotfiles-sync.timer
```

### 推荐的 Shell 别名

在 `.zshrc` 或 `.bashrc` 中添加：

```bash
# Dotfiles 管理别名
alias dm='~/manage.sh'
alias dms='~/manage.sh sync'
alias dmp='~/manage.sh push'
alias dml='~/manage.sh pull'
alias dmst='~/manage.sh status'
```

使用示例：
```bash
dm status        # 查看状态
dms             # 一键同步
dmp             # 推送
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可

MIT License

## 致谢

- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
