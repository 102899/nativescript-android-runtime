# 🚀 NativeScript Android Runtime Maven 仓库

这是一个自建的Maven仓库，用于托管NativeScript Android Runtime的预构建AAR文件。

## 📦 仓库结构

```
maven-repo/
├── scripts/
│   ├── publish-to-maven.sh          # 发布AAR到Maven仓库
│   └── deploy-to-github-pages.sh    # 部署到GitHub Pages
├── repository/                      # Maven仓库目录
│   └── com/nativescript/
│       ├── android-runtime/         # 核心运行时
│       └── widgets/                 # UI组件库
└── README.md                        # 本文档
```

## 🔧 使用方法

### 1. 发布AAR文件到Maven仓库

```bash
# 确保已经构建了AAR文件
./build-and-release.sh

# 发布到Maven仓库（指定版本号）
./maven-repo/scripts/publish-to-maven.sh 1.0.0
```

### 2. 部署到GitHub Pages

```bash
# 部署到GitHub Pages
./maven-repo/scripts/deploy-to-github-pages.sh
```

### 3. 在Android项目中使用

#### 添加仓库

在你的 `build.gradle.kts` 或 `build.gradle` 文件中添加仓库：

```kotlin
repositories {
    maven { url = uri("https://yourname.github.io/nativescript-android-runtime/maven-repo/repository") }
}
```

#### 添加依赖

```kotlin
dependencies {
    implementation("com.nativescript:android-runtime:1.0.0")
    implementation("com.nativescript:widgets:1.0.0")
}
```

## 🌐 GitHub Pages 配置

1. 在GitHub仓库设置中启用GitHub Pages
2. 选择 "Deploy from a branch"
3. 选择 `main` 分支和 `/maven-repo/repository` 目录
4. 等待几分钟后访问: `https://yourname.github.io/nativescript-android-runtime/`

## 📋 版本管理

### 发布新版本

```bash
# 发布新版本
./maven-repo/scripts/publish-to-maven.sh 1.1.0

# 部署到GitHub Pages
./maven-repo/scripts/deploy-to-github-pages.sh
```

### 版本命名规范

- **主版本号**: 重大架构变更或不兼容的API变更
- **次版本号**: 新功能添加，向后兼容
- **修订版本号**: Bug修复和小的改进

示例: `1.2.3`

## 🔍 故障排除

### 常见问题

1. **AAR文件未找到**
   ```bash
   # 确保先构建AAR文件
   ./build-and-release.sh
   ```

2. **GitHub Pages未更新**
   - 检查GitHub Actions是否成功运行
   - 确认GitHub Pages设置正确
   - 等待几分钟让CDN更新

3. **依赖解析失败**
   - 检查仓库URL是否正确
   - 确认版本号是否存在
   - 检查网络连接

### 调试命令

```bash
# 检查Maven仓库结构
find maven-repo/repository -type f -name "*.aar" -o -name "*.pom"

# 验证校验和文件
cd maven-repo/repository
find . -name "*.md5" -exec sh -c 'echo "Checking $1"; md5sum -c "$1"' _ {} \;
```

## 📊 仓库统计

- **支持的Android API**: 24+
- **包含的架构**: arm64-v8a, armeabi-v7a, x86, x86_64
- **文件格式**: AAR (Android Archive)
- **依赖管理**: Maven/Gradle

## 🤝 贡献指南

1. Fork 本仓库
2. 创建功能分支: `git checkout -b feature/new-feature`
3. 提交更改: `git commit -am 'Add new feature'`
4. 推送分支: `git push origin feature/new-feature`
5. 创建Pull Request

## 📄 许可证

本项目采用 Apache License 2.0 许可证。详见 [LICENSE](../LICENSE) 文件。

## 🔗 相关链接

- [NativeScript 官方文档](https://docs.nativescript.org/)
- [Android 开发指南](https://developer.android.com/guide)
- [Maven 仓库规范](https://maven.apache.org/repository-layout.html)
- [GitHub Pages 文档](https://docs.github.com/en/pages)

---

📝 **注意**: 请将示例中的 `yourname` 替换为你的实际GitHub用户名或组织名。