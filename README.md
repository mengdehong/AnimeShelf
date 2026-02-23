# AnimeShelf

AnimeShelf 是一款基于 Flutter 的本地优先番剧分级管理应用。
你可以使用拖拽交互，把 Bangumi 条目整理到自定义 Tier（SSS/SS/S/A/B...）中，
并保留完全离线可用的个人评级与笔记。

仓库地址：`https://github.com/mengdehong/AnimeShelf`

## 支持平台

| 平台 | 发布形态 | 状态 |
|---|---|---|
| Android | `apk` | 已支持 |
| Linux | 源码编译 + 通用 `tar.gz` 压缩包 + AUR（`animeshelf`） | 已支持 |
| Windows | NSIS `exe` 安装包 | 已支持 |

## 功能亮点

- 分级书架：支持 Tier 区块排序、卡片同级排序、跨级拖拽。
- Bangumi 搜索：支持关键词检索，骨架屏过渡与本地缓存。
- 详情页：Hero 动画 + 毛玻璃信息层，支持本地私密笔记。
- 导出/导入：支持 JSON（`.animeshelf`）、CSV、Markdown。
- 主题切换：樱花粉、B 站红、深色主题。
- 本地优先：基于 Drift/SQLite，离线可浏览已收录内容。

## 开发环境

- Flutter 3.x（Dart 3.x）
- Java 17（Android 构建）
- Linux 桌面构建依赖：`ninja-build`、`libgtk-3-dev`、`liblzma-dev`
- Windows 安装包构建（可选）：NSIS（`makensis`）

## 本地开发

### 1) 安装依赖

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 2) 运行

```bash
flutter run             # Android 设备/模拟器
flutter run -d linux    # Linux 桌面
flutter run -d windows  # Windows 桌面
```

### 3) 质量检查

```bash
dart analyze
flutter test
```

## 构建产物

```bash
flutter build apk --release
flutter build linux --release
flutter build windows --release
```

默认输出路径：

- Android APK：`build/app/outputs/flutter-apk/app-release.apk`
- Linux Bundle：`build/linux/x64/release/bundle/`
- Windows Release：`build/windows/x64/runner/Release/`

## Linux AUR（Arch）

AUR 包名：`animeshelf`（源码编译包）。

安装命令：

```bash
yay -S animeshelf
# 或
paru -S animeshelf
```

仓库内打包文件：

- `linux/packaging/aur/animeshelf/PKGBUILD`
- `linux/packaging/aur/animeshelf/.SRCINFO`
- `linux/packaging/aur/animeshelf/animeshelf.desktop`
- `linux/packaging/aur/animeshelf/animeshelf.jpg`

本地验证打包：

```bash
cd linux/packaging/aur/animeshelf
makepkg -si
```

> 说明：AUR 构建依赖 Git tag `v<版本号>`，例如 `v0.1.0`。

## Windows 安装包（NSIS）

本项目提供 NSIS 安装脚本：`windows/installer/installer.nsi`。

本地打包命令（Windows）：

```bash
makensis /DVERSION=v0.1.0 /DOUTPUT_FILE=dist\AnimeShelf-v0.1.0-windows-x64-setup.exe windows\installer\installer.nsi
```

## Android 签名（Release）

### 1) 生成 keystore

```bash
keytool -genkeypair -v \
  -keystore android/upload-keystore.jks \
  -alias animeshelf \
  -keyalg RSA -keysize 2048 -validity 10000
```

### 2) 配置 `key.properties`

```bash
cp android/key.properties.example android/key.properties
```

然后填写：

- `storePassword`
- `keyPassword`
- `keyAlias`
- `storeFile=../upload-keystore.jks`

> 如果 keystore 为 PKCS12，通常 `keyPassword` 与 `storePassword` 相同。

## GitHub Actions 自动发布

发布工作流：`.github/workflows/release.yml`

触发方式：推送标签 `v*`（例如 `v0.1.0`）后自动构建三端产物并发布到
GitHub Releases。

```bash
git tag v0.1.0
git push origin v0.1.0
```

需要在仓库 Secrets 中配置：

- `KEYSTORE_BASE64`
- `KEY_ALIAS`
- `KEY_PASSWORD`
- `STORE_PASSWORD`

## 项目结构（简版）

```text
lib/
  core/       # 数据库、网络、主题、路由、通用工具
  models/     # Drift 表定义
  features/   # shelf / search / details / settings
test/
  unit/
  widget/
docs/
  PROJECT.md
```

完整设计与架构说明见 `docs/PROJECT.md`。

## 更新日志

见 `CHANGELOG.md`。
