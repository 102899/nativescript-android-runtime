#!/bin/bash

# NativeScript Android Runtime Maven 发布脚本
# 用于将AAR文件发布到自建的Maven仓库（GitHub Pages）

set -e

# 配置
GROUP_ID="com.nativescript"
ARTIFACT_ID="android-runtime"
VERSION="${1:-1.0.0}"
MAVEN_REPO_DIR="maven-repo/repository"
AAR_FILE="release/nativescript-android-runtime.aar"
WIDGETS_AAR_FILE="release/widgets-release.aar"

echo "📦 NativeScript Android Runtime Maven 发布器"
echo "版本: $VERSION"
echo ""

# 检查必要文件
if [ ! -f "$AAR_FILE" ]; then
    echo "❌ 错误: 未找到 $AAR_FILE"
    echo "请先运行 ./build-and-release.sh 生成AAR文件"
    exit 1
fi

if [ ! -f "$WIDGETS_AAR_FILE" ]; then
    echo "❌ 错误: 未找到 $WIDGETS_AAR_FILE"
    exit 1
fi

# 创建Maven仓库目录结构
echo "📁 创建Maven仓库目录结构..."
RUNTIME_DIR="$MAVEN_REPO_DIR/${GROUP_ID//.//}/$ARTIFACT_ID/$VERSION"
WIDGETS_DIR="$MAVEN_REPO_DIR/${GROUP_ID//.//}/widgets/$VERSION"

mkdir -p "$RUNTIME_DIR"
mkdir -p "$WIDGETS_DIR"

# 复制AAR文件
echo "📋 复制AAR文件..."
cp "$AAR_FILE" "$RUNTIME_DIR/$ARTIFACT_ID-$VERSION.aar"
cp "$WIDGETS_AAR_FILE" "$WIDGETS_DIR/widgets-$VERSION.aar"

# 生成POM文件 - Runtime
echo "📄 生成POM文件..."
cat > "$RUNTIME_DIR/$ARTIFACT_ID-$VERSION.pom" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <modelVersion>4.0.0</modelVersion>
  <groupId>$GROUP_ID</groupId>
  <artifactId>$ARTIFACT_ID</artifactId>
  <version>$VERSION</version>
  <packaging>aar</packaging>
  
  <name>NativeScript Android Runtime</name>
  <description>NativeScript runtime for Android applications</description>
  <url>https://github.com/yourname/nativescript-android-runtime</url>
  
  <licenses>
    <license>
      <name>Apache License 2.0</name>
      <url>https://www.apache.org/licenses/LICENSE-2.0</url>
    </license>
  </licenses>
  
  <dependencies>
    <dependency>
      <groupId>androidx.multidx</groupId>
      <artifactId>multidx</artifactId>
      <version>2.0.1</version>
    </dependency>
    <dependency>
      <groupId>$GROUP_ID</groupId>
      <artifactId>widgets</artifactId>
      <version>$VERSION</version>
    </dependency>
  </dependencies>
</project>
EOF

# 生成POM文件 - Widgets
cat > "$WIDGETS_DIR/widgets-$VERSION.pom" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd" xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <modelVersion>4.0.0</modelVersion>
  <groupId>$GROUP_ID</groupId>
  <artifactId>widgets</artifactId>
  <version>$VERSION</version>
  <packaging>aar</packaging>
  
  <name>NativeScript Widgets</name>
  <description>NativeScript UI widgets for Android</description>
  <url>https://github.com/yourname/nativescript-android-runtime</url>
  
  <licenses>
    <license>
      <name>Apache License 2.0</name>
      <url>https://www.apache.org/licenses/LICENSE-2.0</url>
    </license>
  </licenses>
</project>
EOF

# 生成校验和文件
echo "🔐 生成校验和文件..."
generate_checksums() {
    local file=$1
    if command -v md5sum >/dev/null 2>&1; then
        md5sum "$file" | cut -d' ' -f1 > "$file.md5"
    elif command -v md5 >/dev/null 2>&1; then
        md5 -q "$file" > "$file.md5"
    fi
    
    if command -v sha1sum >/dev/null 2>&1; then
        sha1sum "$file" | cut -d' ' -f1 > "$file.sha1"
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 1 "$file" | cut -d' ' -f1 > "$file.sha1"
    fi
}

# 为Runtime文件生成校验和
generate_checksums "$RUNTIME_DIR/$ARTIFACT_ID-$VERSION.aar"
generate_checksums "$RUNTIME_DIR/$ARTIFACT_ID-$VERSION.pom"

# 为Widgets文件生成校验和
generate_checksums "$WIDGETS_DIR/widgets-$VERSION.aar"
generate_checksums "$WIDGETS_DIR/widgets-$VERSION.pom"

# 生成Maven元数据
echo "📋 生成Maven元数据..."

# Runtime metadata
RUNTIME_METADATA_DIR="$MAVEN_REPO_DIR/${GROUP_ID//.//}/$ARTIFACT_ID"
mkdir -p "$RUNTIME_METADATA_DIR"

cat > "$RUNTIME_METADATA_DIR/maven-metadata.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<metadata>
  <groupId>$GROUP_ID</groupId>
  <artifactId>$ARTIFACT_ID</artifactId>
  <versioning>
    <latest>$VERSION</latest>
    <release>$VERSION</release>
    <versions>
      <version>$VERSION</version>
    </versions>
    <lastUpdated>$(date +%Y%m%d%H%M%S)</lastUpdated>
  </versioning>
</metadata>
EOF

# Widgets metadata
WIDGETS_METADATA_DIR="$MAVEN_REPO_DIR/${GROUP_ID//.//}/widgets"
mkdir -p "$WIDGETS_METADATA_DIR"

cat > "$WIDGETS_METADATA_DIR/maven-metadata.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<metadata>
  <groupId>$GROUP_ID</groupId>
  <artifactId>widgets</artifactId>
  <versioning>
    <latest>$VERSION</latest>
    <release>$VERSION</release>
    <versions>
      <version>$VERSION</version>
    </versions>
    <lastUpdated>$(date +%Y%m%d%H%M%S)</lastUpdated>
  </versioning>
</metadata>
EOF

# 生成仓库索引页面
echo "🌐 生成仓库索引页面..."
cat > "$MAVEN_REPO_DIR/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>NativeScript Android Runtime Maven Repository</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #f5f5f5; padding: 20px; border-radius: 5px; }
        .usage { background: #f9f9f9; padding: 15px; border-left: 4px solid #007acc; margin: 20px 0; }
        pre { background: #f4f4f4; padding: 10px; border-radius: 3px; overflow-x: auto; }
        .version { color: #007acc; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 NativeScript Android Runtime Maven Repository</h1>
        <p>自建的Maven仓库，托管NativeScript Android Runtime AAR文件</p>
    </div>
    
    <h2>📦 可用组件</h2>
    <ul>
        <li><strong>android-runtime</strong> - NativeScript运行时核心库</li>
        <li><strong>widgets</strong> - NativeScript UI组件库</li>
    </ul>
    
    <h2>🔧 使用方法</h2>
    <div class="usage">
        <h3>1. 添加仓库</h3>
        <pre><code>repositories {
    maven { url = uri("https://yourname.github.io/nativescript-android-runtime/maven-repo/repository") }
}</code></pre>
        
        <h3>2. 添加依赖</h3>
        <pre><code>dependencies {
    implementation("$GROUP_ID:$ARTIFACT_ID:<span class="version">$VERSION</span>")
    implementation("$GROUP_ID:widgets:<span class="version">$VERSION</span>")
}</code></pre>
    </div>
    
    <h2>📋 版本信息</h2>
    <ul>
        <li>最新版本: <span class="version">$VERSION</span></li>
        <li>发布时间: $(date)</li>
        <li>支持的Android API: 24+</li>
    </ul>
    
    <h2>📁 仓库结构</h2>
    <pre><code>$(find "$MAVEN_REPO_DIR" -type f -name "*.aar" -o -name "*.pom" | sed "s|$MAVEN_REPO_DIR/||" | sort)</code></pre>
    
    <footer style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eee; color: #666;">
        <p>Generated on $(date) | <a href="https://github.com/yourname/nativescript-android-runtime">GitHub Repository</a></p>
    </footer>
</body>
</html>
EOF

echo ""
echo "🎉 Maven仓库发布完成！"
echo "📁 仓库位置: $MAVEN_REPO_DIR"
echo "🌐 索引页面: $MAVEN_REPO_DIR/index.html"
echo ""
echo "📋 发布的组件:"
echo "  - $GROUP_ID:$ARTIFACT_ID:$VERSION"
echo "  - $GROUP_ID:widgets:$VERSION"
echo ""
echo "📤 下一步:"
echo "1. 将 $MAVEN_REPO_DIR 目录推送到 GitHub Pages"
echo "2. 配置 GitHub Pages 指向 maven-repo/repository 目录"
echo "3. 更新文档中的仓库URL"

# 生成GitHub Pages部署脚本
cat > "maven-repo/scripts/deploy-to-github-pages.sh" << 'EOF'
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
EOF

chmod +x "maven-repo/scripts/deploy-to-github-pages.sh"

echo ""
echo "✅ 同时创建了GitHub Pages部署脚本: maven-repo/scripts/deploy-to-github-pages.sh"