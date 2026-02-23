# 📚 AnimeShelf - 项目蓝图 0.1

## 一、 产品定义 (Product Vision)

一款**纯本地化**、**高颜值 (ACG温馨风)**、**重交互**的专属番剧管理 App。核心玩法是基于 Bangumi 元数据，通过直观的拖拽操作（Drag & Drop）对番剧进行私人评级管理。

### 平台范围 (Platforms)

* **首发目标**：Android + Linux + Windows。
* **桌面端策略**：Linux（Wayland）与 Windows 同步支持，Linux 优先源码编译、AUR 与通用安装包分发。
* **分发策略（桌面端）**：Linux 提供源码编译、AUR 包（`animeshelf`）与通用压缩包；Windows 提供 NSIS `exe` 安装包；暂不考虑商店/沙盒打包（Flatpak/Snap/MSIX 等）与平板适配。
* **桌面端产物结构**：`flutter build linux --release` 输出 `bundle/` 目录（含可执行文件、`lib/` 动态库、`data/` 资产）并整体压缩分发；`flutter build windows --release` 生成 Release 目录，由 NSIS 打包为安装器。Linux 依赖 GTK 3.x（主流发行版已内置）；SQLite 通过 `sqlite3_flutter_libs` 随 app 捆绑，无需用户单独安装。

## 二、 核心功能清单 (Feature List)

### 1. Bangumi 资源检索与收录

* **搜索与展示**：支持关键词搜索，展示番名、原名、年份及海报。
* **优雅降级**：网络延迟时展示“骨架屏”或“ACG趣味占位图”。
* **便捷收录**：一键收录，并弹出精美的 BottomSheet 选择归属等级。
* **接口策略**：先使用 Bangumi **公开接口**；如后续出现频率/权限需求再考虑切换到鉴权方案。
* **User-Agent**：所有请求携带固定头 `User-Agent: AnimeShelf/1.0 (https://github.com/mengdehong/AnimeShelf)`，遵循 Bangumi API 使用规范。批量刷新并发上限 ≤ 3，失败后指数退避重试（1s → 2s → 4s，最多 3 次）。

### 1.1 数据边界与刷新 (Data Boundary & Refresh)

* **本地快照**：本地持久化 Bangumi 元数据快照（用于离线浏览与快速打开）。
* **手动刷新**：详情页/条目支持手动刷新。
* **批量更新**：支持对库内条目进行批量更新（队列化、并发受控、失败可重试/可取消）。

### 2. 主看板：私人书架 (The Shelf)

* **布局与排版**：纵向分层 + 自动换行排版。按等级区块从上到下排列，区域内海报网格化铺开。
* **丝滑交互**：长按海报触发悬浮动效，支持同级内排序、跨级拖拽，以及**边缘自动滚动**。
* **收件箱 (Inbox)**：设立“未分类区”，专门存放刚收录还未评级的番剧。
* **等级管理**：完全自定义等级，用户可自由新增等级（如 SS, 弃坑），自定义名称、Emoji 及专属颜色。

### 2.1 排序语义 (Sorting Semantics)

* **Tier 顺序**：通过 `tierSort` 决定等级区块从上到下的排列顺序。
* **Tier 内顺序**：通过 `entryRank` 决定同一等级内卡片的先后顺序。
* **插入式拖拽**：跨级/同级拖拽默认按“目标落点插入”计算新顺序。`entryRank` 使用**双精度浮点区间插入**：新位置 rank = (前一个 rank + 后一个 rank) / 2；Tier 初始化时分配整数间距（如 1000, 2000, 3000…）。当相邻 rank 差值 < 1e-9 时触发低频压缩重排（正常使用下极少触发）。`tierSort` 同理。
* **Inbox 视作 Tier**：Inbox 也拥有自己的顺序与排序规则，逻辑复用。

### 2.2 多季度合并/拆分 (Season Grouping)

* **书架卡片实体（Entry）**：书架展示以“卡片/条目（Entry）”为单位；一个 Entry 可关联 1..N 个 Bangumi `subjectId`，用于“多季合并展示”。
* **拆分/合并**：
  * **拆分**：将指定季（subjectId）从旧 Entry 移动到新 Entry。
  * **合并**：将多个 Entry 的 subject 归并到一个 Entry。
* **默认约束（推荐）**：同一个 `subjectId` 同一时间只归属一个 Entry，以简化刷新/导入/导出与去重逻辑。

### 2.3 Entry 展示策略 (Cover/Title Policy)

* **封面与标题来源**：Entry 的封面/标题默认来自一个“主 Subject”。
* **收录时可控**：用户在收录时可从 Bangumi 返回的条目中选择更喜欢的季作为主 Subject。
* **拆分作为机制**：若某一季需要单独管理（例如第 4 季单独一条），则将该季作为单独 Entry 收录。

### 2.4 交互规模假设 (Interaction Scale Assumptions)

* **目标规模**：优先优化常见使用规模；超大库量/超长单 Tier 列表不作为主要优化目标。
* **拖拽滚动冲突**：移动端以长按进入拖拽为主，边缘自动滚动作为加成；极端长距离跨级拖拽暂不作为核心场景。

### 3. 沉浸式详情页 (Anime Details)

* **视觉过渡**：从主页点击触发**Hero 共享元素动画**。
* **质感设计**：毛玻璃质感 (Glassmorphism) 的信息遮罩层。
* **私密笔记**：纯本地私密“手账/笔记”功能（支持长文本吐槽）。

### 4. 数据备份与导出 (Backup & Export)

* **原生备份**：导出/导入`.json`（或专属后缀`.animeshelf`）全量数据。
* **表格导出**：导出 CSV 格式（含评级、番名、评分、本地长评论），方便 Excel 处理。
* **文档导出**：Markdown 导出，采用优雅的“大纲+引用”策略排版，适合一键分享到博客。
* **导出范围**：默认全量导出（后续如体验更好可增加筛选导出）。

### 5. 视觉与主题引擎 (Design & Theming)

* **设计语言**：Soft UI（大圆角、微阴影、低饱和度色彩）。
* **多主题切换**：内置“樱花粉/奶油白”、“B站经典红”等多套主题。
* **夜间模式**：护眼暗色模式，摒弃纯黑，采用深灰/深紫等有质感的暗黑配色。

### 5.1 离线海报策略 (Offline Posters)

* **优先体验**：如使用体验更好，支持离线可看海报。
* **实现建议**：MVP 优先依赖图片磁盘缓存（成本低）；如需“可控离线”再引入预缓存/空间上限/清理策略。

### 6. 范围与非目标 (Scope & Non-goals)

* **不做集数/进度管理**：MVP 不提供“看到第几集/总集数”的追番进度功能，定位聚焦在分级、排序与笔记记录。

## 三、 技术栈与架构 (Tech Stack & Architecture)

### 1. 核心技术选型

* **开发框架**：Flutter 3.x (主打移动端，潜力支持跨平台)
* **状态管理**：**Riverpod** (`riverpod_generator`,`hooks_riverpod`) - 负责全应用的状态同步与异步请求状态处理。
* **本地数据库**：**Drift (SQLite)** - 基于 SQLite 的关系型持久化库（Flutter Favorite），跨平台支持完善（含 Linux 桌面）。关系型模型对 Entry-Subject 多对多关联更自然，SQLite 在所有目标平台均可通过 `sqlite3_flutter_libs` 捆绑分发。
* **网络通信**：`dio` (请求 Bangumi API)。
* **图片处理**：`cached_network_image` (配合本地占位图和骨架屏)。
* **拖拽支持**：全部使用 Flutter 原生 `Draggable`/`DragTarget`，不引入第三方拖拽库。Tier 内排序与跨 Tier 拖拽均走同一套逻辑，数据量小（< 500 条）无性能压力。

### 2. 架构模式

采用 **Feature-first (按功能模块分包)**，配合 **Repository (仓库模式)** 分离 UI 与数据逻辑：

```text
├── docs/PROJECT.md                                    # Project blueprint (Chinese), read-only reference
├── pubspec.yaml                                       # All dependencies declared
├── analysis_options.yaml                              # Lint rules configured
├── lib/
│   ├── main.dart                                      # App entry point (ProviderScope + MaterialApp.router)
│   ├── core/
│   │   ├── database/app_database.dart                 # Drift @DriftDatabase + seed tiers
│   │   ├── database/app_database.g.dart               # Generated Drift code
│   │   ├── exceptions/api_exception.dart              # ApiException, NetworkTimeoutException, NoConnectionException
│   │   ├── exceptions/database_exception.dart         # DatabaseException
│   │   ├── network/bangumi_client.dart                # Dio client with retry interceptor
│   │   ├── theme/app_theme.dart                       # 3 themes: sakuraPink, bilibiliRed, dark
│   │   ├── theme/theme_notifier.dart                  # @riverpod ThemeNotifier + SharedPreferences
│   │   ├── theme/theme_notifier.g.dart                # Generated
│   │   ├── router.dart                                # GoRouter: /shelf, /search, /details/:entryId, /settings
│   │   ├── providers.dart                             # databaseProvider, bangumiClientProvider
│   │   ├── providers.g.dart                           # Generated
│   │   └── utils/
│   │       ├── rank_utils.dart                        # insertRank, needsRecompression, recompressRanks
│   │       └── export_service.dart                    # JSON/CSV/MD export + JSON import
│   ├── models/
│   │   ├── tier.dart                                  # Drift Tiers table
│   │   ├── subject.dart                               # Drift Subjects table (custom PK: subjectId)
│   │   ├── entry.dart                                 # Drift Entries table
│   │   └── entry_subject.dart                         # Drift EntrySubjects junction table
│   └── features/
│       ├── shelf/
│       │   ├── data/shelf_repository.dart              # Full CRUD, rank math, watchTiersWithEntries
│       │   ├── providers/shelf_provider.dart           # shelfRepositoryProvider, shelfTiersProvider
│       │   ├── providers/shelf_provider.g.dart         # Generated
│       │   └── ui/
│       │       ├── shelf_page.dart                     # Main page with ReorderableListView for tier drag
│       │       ├── tier_section.dart                   # DragTarget + LongPressDraggable for entries
│       │       └── entry_card.dart                     # Poster card with Hero tag
│       ├── search/
│       │   ├── data/
│       │   │   ├── bangumi_subject.dart                # @freezed BangumiSubject
│       │   │   ├── bangumi_subject.freezed.dart        # Generated
│       │   │   ├── bangumi_subject.g.dart              # Generated
│       │   │   └── search_repository.dart              # Bangumi API search + cache
│       │   ├── providers/search_provider.dart          # Debounced search provider
│       │   ├── providers/search_provider.g.dart        # Generated
│       │   └── ui/
│       │       ├── search_page.dart                    # Search field + results + skeleton loading
│       │       └── add_to_shelf_sheet.dart             # Tier selection bottom sheet
│       ├── details/
│       │   ├── providers/details_provider.dart         # EntryDetail with debounced note save
│       │   ├── providers/details_provider.g.dart       # Generated
│       │   └── ui/details_page.dart                   # Glassmorphism + Hero + notes editor
│       └── settings/
│           ├── providers/settings_provider.dart        # exportServiceProvider
│           ├── providers/settings_provider.g.dart      # Generated
│           └── ui/settings_page.dart                   # RadioGroup theme switcher + export/import
└── test/
    ├── unit/
    │   ├── rank_utils_test.dart                        # 23 tests — pure logic
    │   ├── shelf_repository_test.dart                  # 17 tests — in-memory Drift DB
    │   ├── export_service_test.dart                    # 14 tests — in-memory Drift DB
    │   └── search_repository_test.dart                 # 9 tests — mocked Dio via mocktail
    └── widget/
        └── shelf_page_test.dart                        # 14 tests — EntryCard + ShelfPage
```
