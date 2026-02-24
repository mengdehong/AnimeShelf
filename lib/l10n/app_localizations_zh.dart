// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '动漫书架';

  @override
  String get settings => '设置';

  @override
  String get theme => '主题';

  @override
  String get window => '窗口';

  @override
  String get export => '导出';

  @override
  String get import => '导入';

  @override
  String get dataManagement => '数据管理';

  @override
  String get themeBilibiliRed => '哔哩红';

  @override
  String get themeDark => '深色';

  @override
  String get themePixivBlue => 'Pixiv 蓝';

  @override
  String get themeMikuTeal => '初音青';

  @override
  String get hideSystemTitleBar => '隐藏系统标题栏';

  @override
  String get useCustomInAppTitleBarInstead => '改用应用内自定义标题栏';

  @override
  String get restartAppForTitleBarChange => '重启应用后该设置将完整生效。';

  @override
  String get appDisplayName => '应用显示名称';

  @override
  String get exportJsonBackup => '导出 JSON 备份';

  @override
  String get fullBackupJson => '完整备份（.json）';

  @override
  String get exportCsv => '导出 CSV';

  @override
  String get spreadsheetFormat => '电子表格格式';

  @override
  String get exportPlainText => '导出纯文本';

  @override
  String get copiesToClipboardAndExportsTxt => '复制到剪贴板并导出 .txt';

  @override
  String get importJsonBackup => '导入 JSON 备份';

  @override
  String get restoreFromJsonFile => '从 .json 文件恢复';

  @override
  String get pastePlainTextList => '粘贴纯文本列表';

  @override
  String get pasteTextOneAnimePerLine => '粘贴文本，每行一个动画';

  @override
  String get plainTextImportConcurrency => '纯文本导入并发数';

  @override
  String currentRange(int current, int min, int max) {
    return '当前：$current（范围 $min-$max）';
  }

  @override
  String get redownloadImages => '重新下载图片';

  @override
  String get downloadPostersMissingLocalFiles => '下载本地缺失海报的条目图片';

  @override
  String get clearLocalImages => '清除本地图片';

  @override
  String get removeCachedPosterFilesFromDevice => '删除设备中的所有缓存海报文件';

  @override
  String get clearAllEntries => '清空所有条目';

  @override
  String get deletesAllEntriesKeepsTiers => '删除所有条目，保留分组';

  @override
  String get copiedToClipboardFileExportCancelled => '已复制到剪贴板（文件导出已取消）';

  @override
  String get exportCancelled => '导出已取消';

  @override
  String copiedToClipboardAndExportedToPath(String path) {
    return '已复制到剪贴板并导出到 $path';
  }

  @override
  String exportedToPathClipboardFailed(String path) {
    return '已导出到 $path（剪贴板复制失败）';
  }

  @override
  String get copiedToClipboardAndExported => '已复制到剪贴板并完成导出';

  @override
  String get exportCompleteClipboardFailed => '导出完成（剪贴板复制失败）';

  @override
  String exportedToPath(String path) {
    return '已导出到 $path';
  }

  @override
  String get exportComplete => '导出完成';

  @override
  String exportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String unsupportedExportFormat(String format) {
    return '不支持的导出格式：$format';
  }

  @override
  String get saveExportFile => '保存导出文件';

  @override
  String get importBackupQuestion => '导入备份？';

  @override
  String get importBackupWarning => '这将替换当前所有数据，确定继续吗？';

  @override
  String get importComplete => '导入完成';

  @override
  String importFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get inputIsEmpty => '输入内容为空';

  @override
  String get plainTextImportAlreadyRunning => '纯文本导入已在进行中';

  @override
  String get importStartedInBackground => '已在后台开始导入';

  @override
  String get clearAllEntriesQuestion => '清空所有条目？';

  @override
  String get clearAllEntriesWarning =>
      '这将永久删除书架中的所有条目。\n\n你的自定义分组不会被删除。\n\n确定继续吗？';

  @override
  String get clearAll => '全部清空';

  @override
  String get allEntriesCleared => '已清空所有条目';

  @override
  String failedToClearEntries(String error) {
    return '清空条目失败：$error';
  }

  @override
  String get plainTextImportReportTitle => '纯文本导入报告';

  @override
  String get ok => '确定';

  @override
  String get imageDownloadAlreadyRunning => '图片下载任务已在运行';

  @override
  String get clearLocalImagesQuestion => '清除本地图片？';

  @override
  String get clearLocalImagesWarning => '这将删除所有本地缓存海报图片。网络地址会保留，之后可重新下载。';

  @override
  String get clear => '清除';

  @override
  String clearedImagesFreedMb(String freedMb) {
    return '已清除图片（释放 $freedMb MB）';
  }

  @override
  String failedToClearImages(String error) {
    return '清除图片失败：$error';
  }

  @override
  String get name => '名称';

  @override
  String get appNameHint => '动漫书架';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get plainTextInputHint => 'S\nClannad\n\nA\n欢迎加入NHK';

  @override
  String get idle => '空闲';

  @override
  String get downloadingImages => '正在下载图片...';

  @override
  String downloadCompleteProgress(int succeeded, int total) {
    return '下载完成（$succeeded/$total）';
  }

  @override
  String get downloadFailed => '下载失败';

  @override
  String processedSucceeded(int processed, int total, int succeeded) {
    return '已处理：$processed/$total  成功：$succeeded';
  }

  @override
  String get close => '关闭';

  @override
  String get failedToLoadShelf => '加载书架失败';

  @override
  String get newTier => '新建分组';

  @override
  String get tierNameHint => '例如：SSS、SS、S、A...';

  @override
  String get emojiOptional => '表情（可选）';

  @override
  String get emojiHint => '例如：👑';

  @override
  String get addTier => '添加分组';

  @override
  String get noTiersYet => '还没有分组，点击 + 创建一个。';

  @override
  String processedImportedSkipped(
    int processed,
    int total,
    int imported,
    int skipped,
  ) {
    return '已处理：$processed/$total  已导入：$imported  已跳过：$skipped';
  }

  @override
  String currentItem(String item) {
    return '当前：$item';
  }

  @override
  String get cancelImport => '取消导入';

  @override
  String get viewReport => '查看报告';

  @override
  String get importIdle => '导入空闲';

  @override
  String get searchingBangumi => '正在搜索 Bangumi...';

  @override
  String get importingEntries => '正在导入条目...';

  @override
  String get preparingImport => '正在准备导入...';

  @override
  String get cancellingImport => '正在取消导入...';

  @override
  String get importCancelled => '导入已取消';

  @override
  String get importCompleted => '导入完成';

  @override
  String get importFailedStatus => '导入失败';

  @override
  String get searchBangumiHint => '搜索 Bangumi...';

  @override
  String get searchAndAddToGetStarted => '搜索并添加动画即可开始';

  @override
  String get editTier => '编辑分组';

  @override
  String get deleteTier => '删除分组';

  @override
  String get emoji => '表情';

  @override
  String get deleteTierQuestion => '删除分组？';

  @override
  String entriesMovedToInbox(String tierName) {
    return '“$tierName”中的条目将被移动到 Inbox。';
  }

  @override
  String get delete => '删除';

  @override
  String get searchAnimeHint => '搜索动画...';

  @override
  String searchFailed(String error) {
    return '搜索失败：$error';
  }

  @override
  String get retry => '重试';

  @override
  String get typeToSearchBangumi => '输入关键词以搜索 Bangumi';

  @override
  String get noResultsFound => '没有找到结果';

  @override
  String get addToShelf => '添加到书架';

  @override
  String errorWithDetails(String error) {
    return '错误：$error';
  }

  @override
  String get alreadyOnShelf => '已在你的书架中';

  @override
  String get addedToShelf => '已添加到书架';

  @override
  String failedToLoadDetails(String error) {
    return '加载详情失败：$error';
  }

  @override
  String get entryNotFound => '未找到条目';

  @override
  String get unknown => '未知';

  @override
  String get openInBangumi => '在 Bangumi 打开';

  @override
  String get removeFromShelf => '从书架移除';

  @override
  String get summary => '简介';

  @override
  String get privateNotes => '私人笔记';

  @override
  String get writeThoughtsHint => '写下你的想法...';

  @override
  String get staff => '制作人员';

  @override
  String get director => '导演';

  @override
  String get studio => '制作公司';

  @override
  String get moveToTier => '移动到分组';

  @override
  String get removeFromShelfQuestion => '从书架移除？';

  @override
  String get removeFromShelfConfirm => '确定要将这部动画从书架中移除吗？此操作无法撤销。';
}
