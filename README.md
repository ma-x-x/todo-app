# Todo App - 跨平台待办事项应用

一个使用 Flutter 开发的现代化待办事项应用，支持多平台（iOS、Android、Web）。

## 功能特性

- 📝 待办事项管理（创建、编辑、删除）
- 📁 分类管理
- 🔔 提醒功能
- 🌙 深色模式
- 🌍 多语言支持（中文、英文）
- 📊 数据统计和分析
- 💾 数据导入导出
- ⚡️ 离线支持

## 开发环境配置

### 1. 安装 Flutter SDK

1. 访问 [Flutter 官网](https://flutter.dev/docs/get-started/install) 下载适合你操作系统的 Flutter SDK
2. 解压 SDK 到你想安装的目录
3. 添加 Flutter 到系统环境变量

Windows:
```bash
# 添加 Flutter 到系统 PATH
setx PATH "%PATH%;C:\path\to\flutter\bin"
```

macOS/Linux:
```bash
# 添加以下行到 ~/.bashrc 或 ~/.zshrc
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. 安装开发工具

推荐使用以下 IDE 之一：
- [Visual Studio Code](https://code.visualstudio.com/) + Flutter 插件
- [Android Studio](https://developer.android.com/studio) + Flutter 插件

### 3. 检查开发环境

运行以下命令检查环境配置：
```bash
flutter doctor
```

按照提示解决所有标记为 ❌ 的问题。

## 项目设置

1. 克隆项目：
```bash
git clone https://github.com/yourusername/todo_app.git
cd todo_app
```

2. 安装依赖：
```bash
flutter pub get
```

3. 运行项目：
```bash
flutter run
```

## 平台特定配置

### Android 开发

1. 安装 Android Studio
2. 创建 Android 虚拟设备（AVD）
3. 配置 `android/app/build.gradle`：
```gradle
android {
    compileSdkVersion 33
    ...
}
```

### iOS 开发（需要 Mac）

1. 安装 Xcode
2. 安装 iOS 模拟器
3. 配置开发证书：
```bash
# 打开 Xcode 项目
open ios/Runner.xcworkspace
```
在 Xcode 中配置你的开发团队。

### Web 开发

无需特殊配置，直接运行：
```bash
flutter run -d chrome
```

## 打包发布

### Android 打包

1. 创建密钥：
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. 配置密钥信息：
创建 `android/key.properties` 文件：
```properties
storePassword=<密钥库密码>
keyPassword=<密钥密码>
keyAlias=upload
storeFile=upload-keystore.jks
```

3. 生成 APK：
```bash
flutter build apk
```
生成的 APK 位于 `build/app/outputs/flutter-apk/app-release.apk`

### iOS 打包（需要 Mac）

1. 在 Xcode 中配置证书和描述文件
2. 运行打包命令：
```bash
flutter build ipa
```
生成的 IPA 位于 `build/ios/archive/Runner.ipa`

### Web 打包

```bash
flutter build web
```
生成的文件位于 `build/web` 目录

## 常见问题

### Q: 运行 flutter run 报错
A: 尝试以下步骤：
1. 运行 `flutter clean`
2. 运行 `flutter pub get`
3. 重新运行 `flutter run`

### Q: iOS 构建失败
A: 确保：
1. Xcode 版本最新
2. 已配置有效的开发者证书
3. 运行 `pod install` 在 ios 目录下

### Q: Android 构建失败
A: 检查：
1. Android SDK 版本是否正确
2. Gradle 版本是否兼容
3. 运行 `flutter clean` 后重试

## 贡献指南

1. Fork 项目
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交改动：`git commit -m 'Add some AmazingFeature'`
4. 推送分支：`git push origin feature/AmazingFeature`
5. 提交 Pull Request

## 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系方式

作者邮箱：your.email@example.com

项目链接：[https://github.com/yourusername/todo_app](https://github.com/yourusername/todo_app)
