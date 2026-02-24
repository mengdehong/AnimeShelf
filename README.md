# AnimeShelf

AnimeShelf 是一款基于 Flutter 的本地番剧记录与分级管理应用。
通过拖拽交互把 Bangumi 条目整理到自定义 Tier（SSS/SS/S/A/B…）中，
个人评级与笔记完全离线可用。

仓库地址：https://github.com/mengdehong/AnimeShelf

## 支持平台

| 平台 | 发布形态 |
|---|---|
| Android | APK |
| Linux | 源码编译 / 通用 `tar.gz` 压缩包 / AUR（`animeshelf`） |
| Windows | NSIS `exe` 安装包 |

### Linux（Arch）安装

```bash
yay -S animeshelf
# 或
paru -S animeshelf
```

## 功能亮点

- **分级书架**：响应式网格布局，支持 Tier 区块排序、卡片同级排序、跨级拖拽，支持边缘自动滚动。
- **分组管理**：统一的管理面板，合并自定义等级的新建与排序流程。
- **Bangumi 搜索**：全局统一的搜索栏体验，关键词检索，骨架屏过渡与本地缓存。
- **详情页**：Hero 共享元素动画 + 毛玻璃信息层，支持本地私密笔记。
- **导出/导入**：支持 JSON（`.animeshelf`）、CSV、纯文本（`.txt`）三种格式，具备健壮的去重与关系恢复机制。
- **本地化与主题**：完整实现全应用中文本地化支持；内置多套主题。
- **本地优先**：基于 Drift/SQLite，离线可浏览已收录内容。

## 文档

- [产品蓝图与架构说明](docs/PROJECT.md)
- [开发者指南（构建/测试/发布）](docs/DEVELOPMENT.md)
