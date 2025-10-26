# NativeScript Android Runtime

这是一个独立的AAR库，包含了在Android项目中集成NativeScript所需的所有运行时组件。

## 包含内容


- **JAR文件**: NativeScript核心运行时库
  - `jetified-nativescript-optimized-with-inspector-api.jar`
  - `jetified-widgets-release-api.jar`

- **原生库文件**: 支持多种CPU架构的.so文件
  - `libNativeScript.so` - NativeScript核心运行时
  - `libc++_shared.so` - C++标准库
  - 支持架构: arm64-v8a, armeabi-v7a, x86, x86_64

- **权限配置**: NativeScript运行所需的基本权限

## 使用方法

### 1. 添加依赖

在你的Android项目的`build.gradle.kts`文件中添加：

```kotlin
dependencies {
    implementation("com.nativescript:android-runtime:1.0.0")
}
```

### 2. 配置权限

确保你的主项目`AndroidManifest.xml`包含必要的权限（如果AAR中的权限不够）：

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 3. 启用MultiDex

在你的Application类中启用MultiDex支持：

```kotlin
class MyApplication : MultiDexApplication() {
    // 你的应用代码
}
```

## 版本信息

- 版本: 1.0.0
- 最低Android SDK: 24
- 目标Android SDK: 34
- 编译SDK: 34

## 注意事项

1. 此库已包含MultiDex支持，无需额外配置
2. 所有必要的原生库文件已预打包
3. 支持所有主流Android设备架构
4. 与Android Gradle Plugin 8.0+兼容

## 构建说明

要构建此AAR库：

```bash
./gradlew assembleRelease
```

生成的AAR文件位于：`build/outputs/aar/`