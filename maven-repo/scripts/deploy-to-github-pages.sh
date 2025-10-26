#!/bin/bash

# 部署Maven仓库到GitHub Pages

set -e

echo "🚀 部署Maven仓库到GitHub Pages..."

# 检查是否在git仓库中
if [ ! -d ".git" ]; then
    echo "❌ 错误: 不在git仓库中"
    exit 1
fi

# 检查maven-repo目录是否存在
if [ ! -d "maven-repo/repository" ]; then
    echo "❌ 错误: maven-repo/repository 目录不存在"
    echo "请先运行 ./maven-repo/scripts/publish-to-maven.sh"
    exit 1
fi

# 添加文件到git
echo "📁 添加文件到git..."
git add maven-repo/

# 提交更改
echo "💾 提交更改..."
git commit -m "Update Maven repository with latest AAR files" || echo "没有新的更改需要提交"

# 推送到远程仓库
echo "📤 推送到远程仓库..."
git push origin main

echo ""
echo "🎉 部署完成！"
echo "📋 下一步:"
echo "1. 在GitHub仓库设置中启用GitHub Pages"
echo "2. 选择 'Deploy from a branch'"
echo "3. 选择 'main' 分支和 '/maven-repo/repository' 目录"
echo "4. 等待几分钟后访问: https://yourname.github.io/nativescript-android-runtime/"
