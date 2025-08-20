#!/bin/bash

# Dotfiles 清理脚本 - 移除大文件和第三方代码

echo "🧹 开始清理dotfiles仓库..."

# 设置dotfiles函数
dotfiles() {
    /usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

# 1. 移除背景图片文件
echo "📸 移除背景图片文件..."
for i in {000..052}; do
    if dotfiles ls-files --error-unmatch .config/i3/background/bg${i}.png >/dev/null 2>&1; then
        dotfiles rm .config/i3/background/bg${i}.png
    fi
done

# 2. 移除powerlevel10k主题文件（建议通过包管理器安装）
echo "🎨 保留powerlevel10k主题文件（用户需要同步）..."
# 注释掉主题删除部分
# if dotfiles ls-files --error-unmatch .config/zsh/themes/ >/dev/null 2>&1; then
#     dotfiles rm -r .config/zsh/themes/ 2>/dev/null || true
# fi

# 3. 保留zsh插件（用户需要同步）
echo "🔌 保留zsh插件（用户需要同步）..."
# 注释掉插件删除部分
# if dotfiles ls-files --error-unmatch .config/zsh/plugins/ >/dev/null 2>&1; then
#     dotfiles rm -r .config/zsh/plugins/ 2>/dev/null || true
# fi

# if dotfiles ls-files --error-unmatch .config/zsh/zsh-autosuggestions/ >/dev/null 2>&1; then
#     dotfiles rm -r .config/zsh/zsh-autosuggestions/ 2>/dev/null || true
# fi

# 4. 更新.gitignore（已手动完成）
echo "📝 .gitignore已更新"

echo "✨ 清理完成！"
echo "📊 请运行以下命令查看状态："
echo "   ./manage.sh status"
echo "🚀 如果满意结果，请运行："
echo "   ./manage.sh commit '精简仓库：移除背景图片文件，保留zsh配置'"
echo ""
echo "ℹ️  注意："
echo "   - 保留了zsh主题和插件配置以便同步"
echo "   - 只移除了i3背景图片文件（主要的存储占用）"
