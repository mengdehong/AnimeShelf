import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('zh')];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'动漫书架'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get theme;

  /// No description provided for @window.
  ///
  /// In zh, this message translates to:
  /// **'窗口'**
  String get window;

  /// No description provided for @shelfLayout.
  ///
  /// In zh, this message translates to:
  /// **'书架布局'**
  String get shelfLayout;

  /// No description provided for @export.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get export;

  /// No description provided for @import.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get import;

  /// No description provided for @dataManagement.
  ///
  /// In zh, this message translates to:
  /// **'数据管理'**
  String get dataManagement;

  /// No description provided for @themeBilibiliRed.
  ///
  /// In zh, this message translates to:
  /// **'哔哩红'**
  String get themeBilibiliRed;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @themePixivBlue.
  ///
  /// In zh, this message translates to:
  /// **'Pixiv 蓝'**
  String get themePixivBlue;

  /// No description provided for @themeMikuTeal.
  ///
  /// In zh, this message translates to:
  /// **'初音青'**
  String get themeMikuTeal;

  /// No description provided for @hideSystemTitleBar.
  ///
  /// In zh, this message translates to:
  /// **'隐藏系统标题栏'**
  String get hideSystemTitleBar;

  /// No description provided for @useCustomInAppTitleBarInstead.
  ///
  /// In zh, this message translates to:
  /// **'改用应用内自定义标题栏'**
  String get useCustomInAppTitleBarInstead;

  /// No description provided for @restartAppForTitleBarChange.
  ///
  /// In zh, this message translates to:
  /// **'重启应用后该设置将完整生效。'**
  String get restartAppForTitleBarChange;

  /// No description provided for @appDisplayName.
  ///
  /// In zh, this message translates to:
  /// **'应用显示名称'**
  String get appDisplayName;

  /// No description provided for @exportJsonBackup.
  ///
  /// In zh, this message translates to:
  /// **'导出 JSON 备份'**
  String get exportJsonBackup;

  /// No description provided for @fullBackupJson.
  ///
  /// In zh, this message translates to:
  /// **'完整备份（.json）'**
  String get fullBackupJson;

  /// No description provided for @exportCsv.
  ///
  /// In zh, this message translates to:
  /// **'导出 CSV'**
  String get exportCsv;

  /// No description provided for @spreadsheetFormat.
  ///
  /// In zh, this message translates to:
  /// **'电子表格格式'**
  String get spreadsheetFormat;

  /// No description provided for @exportPlainText.
  ///
  /// In zh, this message translates to:
  /// **'导出纯文本'**
  String get exportPlainText;

  /// No description provided for @copiesToClipboardAndExportsTxt.
  ///
  /// In zh, this message translates to:
  /// **'复制到剪贴板并导出 .txt'**
  String get copiesToClipboardAndExportsTxt;

  /// No description provided for @importJsonBackup.
  ///
  /// In zh, this message translates to:
  /// **'导入 JSON 备份'**
  String get importJsonBackup;

  /// No description provided for @restoreFromJsonFile.
  ///
  /// In zh, this message translates to:
  /// **'从 .json 文件恢复'**
  String get restoreFromJsonFile;

  /// No description provided for @pastePlainTextList.
  ///
  /// In zh, this message translates to:
  /// **'粘贴纯文本列表'**
  String get pastePlainTextList;

  /// No description provided for @pasteTextOneAnimePerLine.
  ///
  /// In zh, this message translates to:
  /// **'粘贴文本，每行一个动画'**
  String get pasteTextOneAnimePerLine;

  /// No description provided for @plainTextImportConcurrency.
  ///
  /// In zh, this message translates to:
  /// **'纯文本导入并发数'**
  String get plainTextImportConcurrency;

  /// No description provided for @entriesPerTierRow.
  ///
  /// In zh, this message translates to:
  /// **'每行条目数'**
  String get entriesPerTierRow;

  /// No description provided for @currentRange.
  ///
  /// In zh, this message translates to:
  /// **'当前：{current}（范围 {min}-{max}）'**
  String currentRange(int current, int min, int max);

  /// No description provided for @redownloadImages.
  ///
  /// In zh, this message translates to:
  /// **'重新下载图片'**
  String get redownloadImages;

  /// No description provided for @downloadPostersMissingLocalFiles.
  ///
  /// In zh, this message translates to:
  /// **'下载本地缺失海报的条目图片'**
  String get downloadPostersMissingLocalFiles;

  /// No description provided for @clearLocalImages.
  ///
  /// In zh, this message translates to:
  /// **'清除本地图片'**
  String get clearLocalImages;

  /// No description provided for @removeCachedPosterFilesFromDevice.
  ///
  /// In zh, this message translates to:
  /// **'删除设备中的所有缓存海报文件'**
  String get removeCachedPosterFilesFromDevice;

  /// No description provided for @clearAllEntries.
  ///
  /// In zh, this message translates to:
  /// **'清空所有条目'**
  String get clearAllEntries;

  /// No description provided for @deletesAllEntriesKeepsTiers.
  ///
  /// In zh, this message translates to:
  /// **'删除所有条目，保留分组'**
  String get deletesAllEntriesKeepsTiers;

  /// No description provided for @copiedToClipboardFileExportCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板（文件导出已取消）'**
  String get copiedToClipboardFileExportCancelled;

  /// No description provided for @exportCancelled.
  ///
  /// In zh, this message translates to:
  /// **'导出已取消'**
  String get exportCancelled;

  /// No description provided for @copiedToClipboardAndExportedToPath.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板并导出到 {path}'**
  String copiedToClipboardAndExportedToPath(String path);

  /// No description provided for @exportedToPathClipboardFailed.
  ///
  /// In zh, this message translates to:
  /// **'已导出到 {path}（剪贴板复制失败）'**
  String exportedToPathClipboardFailed(String path);

  /// No description provided for @copiedToClipboardAndExported.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板并完成导出'**
  String get copiedToClipboardAndExported;

  /// No description provided for @exportCompleteClipboardFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出完成（剪贴板复制失败）'**
  String get exportCompleteClipboardFailed;

  /// No description provided for @exportedToPath.
  ///
  /// In zh, this message translates to:
  /// **'已导出到 {path}'**
  String exportedToPath(String path);

  /// No description provided for @exportComplete.
  ///
  /// In zh, this message translates to:
  /// **'导出完成'**
  String get exportComplete;

  /// No description provided for @exportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败：{error}'**
  String exportFailed(String error);

  /// No description provided for @unsupportedExportFormat.
  ///
  /// In zh, this message translates to:
  /// **'不支持的导出格式：{format}'**
  String unsupportedExportFormat(String format);

  /// No description provided for @saveExportFile.
  ///
  /// In zh, this message translates to:
  /// **'保存导出文件'**
  String get saveExportFile;

  /// No description provided for @importBackupQuestion.
  ///
  /// In zh, this message translates to:
  /// **'导入备份？'**
  String get importBackupQuestion;

  /// No description provided for @importBackupWarning.
  ///
  /// In zh, this message translates to:
  /// **'这将替换当前所有数据，确定继续吗？'**
  String get importBackupWarning;

  /// No description provided for @importComplete.
  ///
  /// In zh, this message translates to:
  /// **'导入完成'**
  String get importComplete;

  /// No description provided for @importFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败：{error}'**
  String importFailed(String error);

  /// No description provided for @inputIsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'输入内容为空'**
  String get inputIsEmpty;

  /// No description provided for @plainTextImportAlreadyRunning.
  ///
  /// In zh, this message translates to:
  /// **'纯文本导入已在进行中'**
  String get plainTextImportAlreadyRunning;

  /// No description provided for @importStartedInBackground.
  ///
  /// In zh, this message translates to:
  /// **'已在后台开始导入'**
  String get importStartedInBackground;

  /// No description provided for @clearAllEntriesQuestion.
  ///
  /// In zh, this message translates to:
  /// **'清空所有条目？'**
  String get clearAllEntriesQuestion;

  /// No description provided for @clearAllEntriesWarning.
  ///
  /// In zh, this message translates to:
  /// **'这将永久删除书架中的所有条目。\n\n你的自定义分组不会被删除。\n\n确定继续吗？'**
  String get clearAllEntriesWarning;

  /// No description provided for @clearAll.
  ///
  /// In zh, this message translates to:
  /// **'全部清空'**
  String get clearAll;

  /// No description provided for @allEntriesCleared.
  ///
  /// In zh, this message translates to:
  /// **'已清空所有条目'**
  String get allEntriesCleared;

  /// No description provided for @failedToClearEntries.
  ///
  /// In zh, this message translates to:
  /// **'清空条目失败：{error}'**
  String failedToClearEntries(String error);

  /// No description provided for @plainTextImportReportTitle.
  ///
  /// In zh, this message translates to:
  /// **'纯文本导入报告'**
  String get plainTextImportReportTitle;

  /// No description provided for @ok.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get ok;

  /// No description provided for @imageDownloadAlreadyRunning.
  ///
  /// In zh, this message translates to:
  /// **'图片下载任务已在运行'**
  String get imageDownloadAlreadyRunning;

  /// No description provided for @clearLocalImagesQuestion.
  ///
  /// In zh, this message translates to:
  /// **'清除本地图片？'**
  String get clearLocalImagesQuestion;

  /// No description provided for @clearLocalImagesWarning.
  ///
  /// In zh, this message translates to:
  /// **'这将删除所有本地缓存海报图片。网络地址会保留，之后可重新下载。'**
  String get clearLocalImagesWarning;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get clear;

  /// No description provided for @clearedImagesFreedMb.
  ///
  /// In zh, this message translates to:
  /// **'已清除图片（释放 {freedMb} MB）'**
  String clearedImagesFreedMb(String freedMb);

  /// No description provided for @failedToClearImages.
  ///
  /// In zh, this message translates to:
  /// **'清除图片失败：{error}'**
  String failedToClearImages(String error);

  /// No description provided for @name.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get name;

  /// No description provided for @appNameHint.
  ///
  /// In zh, this message translates to:
  /// **'动漫书架'**
  String get appNameHint;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @plainTextInputHint.
  ///
  /// In zh, this message translates to:
  /// **'S\nClannad\n\nA\n欢迎加入NHK'**
  String get plainTextInputHint;

  /// No description provided for @idle.
  ///
  /// In zh, this message translates to:
  /// **'空闲'**
  String get idle;

  /// No description provided for @downloadingImages.
  ///
  /// In zh, this message translates to:
  /// **'正在下载图片...'**
  String get downloadingImages;

  /// No description provided for @downloadCompleteProgress.
  ///
  /// In zh, this message translates to:
  /// **'下载完成（{succeeded}/{total}）'**
  String downloadCompleteProgress(int succeeded, int total);

  /// No description provided for @downloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载失败'**
  String get downloadFailed;

  /// No description provided for @processedSucceeded.
  ///
  /// In zh, this message translates to:
  /// **'已处理：{processed}/{total}  成功：{succeeded}'**
  String processedSucceeded(int processed, int total, int succeeded);

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @failedToLoadShelf.
  ///
  /// In zh, this message translates to:
  /// **'加载书架失败'**
  String get failedToLoadShelf;

  /// No description provided for @newTier.
  ///
  /// In zh, this message translates to:
  /// **'新建分组'**
  String get newTier;

  /// No description provided for @tierNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：SSS、SS、S、A...'**
  String get tierNameHint;

  /// No description provided for @emojiOptional.
  ///
  /// In zh, this message translates to:
  /// **'表情（可选）'**
  String get emojiOptional;

  /// No description provided for @emojiHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：👑'**
  String get emojiHint;

  /// No description provided for @addTier.
  ///
  /// In zh, this message translates to:
  /// **'添加分组'**
  String get addTier;

  /// No description provided for @noTiersYet.
  ///
  /// In zh, this message translates to:
  /// **'还没有分组，点击 + 创建一个。'**
  String get noTiersYet;

  /// No description provided for @processedImportedSkipped.
  ///
  /// In zh, this message translates to:
  /// **'已处理：{processed}/{total}  已导入：{imported}  已跳过：{skipped}'**
  String processedImportedSkipped(
    int processed,
    int total,
    int imported,
    int skipped,
  );

  /// No description provided for @currentItem.
  ///
  /// In zh, this message translates to:
  /// **'当前：{item}'**
  String currentItem(String item);

  /// No description provided for @cancelImport.
  ///
  /// In zh, this message translates to:
  /// **'取消导入'**
  String get cancelImport;

  /// No description provided for @viewReport.
  ///
  /// In zh, this message translates to:
  /// **'查看报告'**
  String get viewReport;

  /// No description provided for @importIdle.
  ///
  /// In zh, this message translates to:
  /// **'导入空闲'**
  String get importIdle;

  /// No description provided for @searchingBangumi.
  ///
  /// In zh, this message translates to:
  /// **'正在搜索 Bangumi...'**
  String get searchingBangumi;

  /// No description provided for @importingEntries.
  ///
  /// In zh, this message translates to:
  /// **'正在导入条目...'**
  String get importingEntries;

  /// No description provided for @preparingImport.
  ///
  /// In zh, this message translates to:
  /// **'正在准备导入...'**
  String get preparingImport;

  /// No description provided for @cancellingImport.
  ///
  /// In zh, this message translates to:
  /// **'正在取消导入...'**
  String get cancellingImport;

  /// No description provided for @importCancelled.
  ///
  /// In zh, this message translates to:
  /// **'导入已取消'**
  String get importCancelled;

  /// No description provided for @importCompleted.
  ///
  /// In zh, this message translates to:
  /// **'导入完成'**
  String get importCompleted;

  /// No description provided for @importFailedStatus.
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get importFailedStatus;

  /// No description provided for @searchBangumiHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索 Bangumi...'**
  String get searchBangumiHint;

  /// No description provided for @searchAndAddToGetStarted.
  ///
  /// In zh, this message translates to:
  /// **'搜索并添加动画即可开始'**
  String get searchAndAddToGetStarted;

  /// No description provided for @editTier.
  ///
  /// In zh, this message translates to:
  /// **'编辑分组'**
  String get editTier;

  /// No description provided for @deleteTier.
  ///
  /// In zh, this message translates to:
  /// **'删除分组'**
  String get deleteTier;

  /// No description provided for @emoji.
  ///
  /// In zh, this message translates to:
  /// **'表情'**
  String get emoji;

  /// No description provided for @deleteTierQuestion.
  ///
  /// In zh, this message translates to:
  /// **'删除分组？'**
  String get deleteTierQuestion;

  /// No description provided for @entriesMovedToInbox.
  ///
  /// In zh, this message translates to:
  /// **'“{tierName}”中的条目将被移动到 Inbox。'**
  String entriesMovedToInbox(String tierName);

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @searchAnimeHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索动画...'**
  String get searchAnimeHint;

  /// No description provided for @searchFailed.
  ///
  /// In zh, this message translates to:
  /// **'搜索失败：{error}'**
  String searchFailed(String error);

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @typeToSearchBangumi.
  ///
  /// In zh, this message translates to:
  /// **'输入关键词以搜索 Bangumi'**
  String get typeToSearchBangumi;

  /// No description provided for @noResultsFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到结果'**
  String get noResultsFound;

  /// No description provided for @addToShelf.
  ///
  /// In zh, this message translates to:
  /// **'添加到书架'**
  String get addToShelf;

  /// No description provided for @errorWithDetails.
  ///
  /// In zh, this message translates to:
  /// **'错误：{error}'**
  String errorWithDetails(String error);

  /// No description provided for @alreadyOnShelf.
  ///
  /// In zh, this message translates to:
  /// **'已在你的书架中'**
  String get alreadyOnShelf;

  /// No description provided for @addedToShelf.
  ///
  /// In zh, this message translates to:
  /// **'已添加到书架'**
  String get addedToShelf;

  /// No description provided for @failedToLoadDetails.
  ///
  /// In zh, this message translates to:
  /// **'加载详情失败：{error}'**
  String failedToLoadDetails(String error);

  /// No description provided for @entryNotFound.
  ///
  /// In zh, this message translates to:
  /// **'未找到条目'**
  String get entryNotFound;

  /// No description provided for @unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown;

  /// No description provided for @openInBangumi.
  ///
  /// In zh, this message translates to:
  /// **'在 Bangumi 打开'**
  String get openInBangumi;

  /// No description provided for @removeFromShelf.
  ///
  /// In zh, this message translates to:
  /// **'从书架移除'**
  String get removeFromShelf;

  /// No description provided for @summary.
  ///
  /// In zh, this message translates to:
  /// **'简介'**
  String get summary;

  /// No description provided for @privateNotes.
  ///
  /// In zh, this message translates to:
  /// **'私人笔记'**
  String get privateNotes;

  /// No description provided for @writeThoughtsHint.
  ///
  /// In zh, this message translates to:
  /// **'写下你的想法...'**
  String get writeThoughtsHint;

  /// No description provided for @staff.
  ///
  /// In zh, this message translates to:
  /// **'制作人员'**
  String get staff;

  /// No description provided for @director.
  ///
  /// In zh, this message translates to:
  /// **'导演'**
  String get director;

  /// No description provided for @studio.
  ///
  /// In zh, this message translates to:
  /// **'制作公司'**
  String get studio;

  /// No description provided for @moveToTier.
  ///
  /// In zh, this message translates to:
  /// **'移动到分组'**
  String get moveToTier;

  /// No description provided for @removeFromShelfQuestion.
  ///
  /// In zh, this message translates to:
  /// **'从书架移除？'**
  String get removeFromShelfQuestion;

  /// No description provided for @removeFromShelfConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要将这部动画从书架中移除吗？此操作无法撤销。'**
  String get removeFromShelfConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
