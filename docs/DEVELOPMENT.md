# AnimeShelf — 开发者指南

完整架构与产品设计见 [PROJECT.md](PROJECT.md)。

---

## 开发环境要求

| 工具 | 版本要求 |
|---|---|
| Flutter / Dart | 3.x / Dart 3.x |
| Java | 17（Android 构建） |
| Linux 桌面构建依赖 | `ninja-build`、`libgtk-3-dev`、`liblzma-dev` |
| Windows 安装包构建（可选） | NSIS（`makensis`） |

---

## 本地开发

### 1) 安装依赖与代码生成

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

代码生成（Drift、Riverpod、Freezed）在文件变更后需重新执行，也可使用 watch 模式：

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### 2) 运行

```bash
flutter run             # Android 设备/模拟器
flutter run -d linux    # Linux 桌面
flutter run -d windows  # Windows 桌面
```

### 3) 质量检查

```bash
dart analyze                      # 静态分析
dart format --set-exit-if-changed .  # 格式检查（CI 使用）
dart format .                     # 格式化全部文件
dart fix --apply                  # 应用自动修复
flutter test                      # 运行全部测试
flutter test --coverage           # 生成覆盖率报告
```

---

## 构建产物

```bash
flutter build apk --release       # Android APK
flutter build linux --release     # Linux 桌面
flutter build windows --release   # Windows 桌面
```

默认输出路径：

| 平台 | 输出路径 |
|---|---|
| Android APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Linux Bundle | `build/linux/x64/release/bundle/` |
| Windows Release | `build/windows/x64/runner/Release/` |

---

## Linux AUR

AUR 包名：`animeshelf`（源码编译包）。

```bash
yay -S animeshelf
# 或
paru -S animeshelf
```

仓库内打包文件：

```
linux/packaging/aur/animeshelf/PKGBUILD
linux/packaging/aur/animeshelf/.SRCINFO
linux/packaging/aur/animeshelf/animeshelf.desktop
linux/packaging/aur/animeshelf/animeshelf.png
```

本地验证打包：

```bash
cd linux/packaging/aur/animeshelf
makepkg -si
```

> AUR 构建依赖 Git tag `v<版本号>`，例如 `v0.1.0`。

---

## Windows 安装包（NSIS）

安装脚本：`windows/installer/installer.nsi`

本地打包命令（在 Windows 上执行）：

```bash
makensis /DVERSION=v0.1.0 /DOUTPUT_FILE=dist\AnimeShelf-v0.1.0-windows-x64-setup.exe windows\installer\installer.nsi
```

---

## 项目结构

```text
lib/
  core/       # 数据库、网络、主题、路由、通用工具
  models/     # Drift 表定义
  features/   # shelf / search / details / settings
test/
  unit/       # 纯逻辑单元测试
  widget/     # Widget 集成测试
docs/
  PROJECT.md  # 产品蓝图与完整架构说明
  DEVELOPMENT.md  # 本文件
```

代码风格、命名规范与贡献规范详见仓库根目录的 `AGENTS.md`。
