import 'dart:convert';
import 'dart:io';

import 'package:anime_shelf/core/app_name_notifier.dart';
import 'package:anime_shelf/core/providers.dart';
import 'package:anime_shelf/core/theme/app_theme.dart';
import 'package:anime_shelf/core/theme/theme_notifier.dart';
import 'package:anime_shelf/core/utils/export_service.dart';
import 'package:anime_shelf/core/utils/plain_text_import_report_formatter.dart';
import 'package:anime_shelf/core/window/fused_app_bar.dart';
import 'package:anime_shelf/core/window/window_settings_notifier.dart';
import 'package:anime_shelf/features/settings/providers/settings_provider.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:anime_shelf/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Settings page — theme switching, backup/export, and import.
class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeIndex = ref.watch(themeNotifierProvider);
    final hideTitleBar = ref.watch(windowSettingsNotifierProvider);
    final appName = ref.watch(appNameNotifierProvider);
    final importTaskState = ref.watch(plainTextImportTaskProvider);
    final importConcurrency = ref.watch(plainTextImportConcurrencyProvider);
    final shelfEntryColumns = ref.watch(shelfEntryColumnsProvider);
    final imageTaskState = ref.watch(imageRedownloadTaskProvider);

    // Pick whichever bottom sheet is active (import takes priority).
    final showImportPanel = importTaskState.showPanel;
    final showImagePanel = !showImportPanel && imageTaskState.showPanel;
    final hasBottomPanel = showImportPanel || showImagePanel;

    return Scaffold(
      appBar: FusedAppBar(title: Text(l10n.settings)),
      bottomSheet: showImportPanel
          ? _PlainTextImportBottomSheet(
              state: importTaskState,
              onCancel: () {
                ref.read(plainTextImportTaskProvider.notifier).cancelImport();
              },
              onClose: () {
                ref.read(plainTextImportTaskProvider.notifier).closePanel();
              },
              onViewReport: importTaskState.report == null
                  ? null
                  : () {
                      _showPlainTextImportReport(
                        context,
                        importTaskState.report!,
                      );
                    },
            )
          : showImagePanel
          ? _ImageTaskBottomSheet(
              state: imageTaskState,
              onClose: () {
                ref.read(imageRedownloadTaskProvider.notifier).closePanel();
              },
            )
          : null,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, hasBottomPanel ? 180 : 16),
        children: [
          // ── Theme Section ──
          Text(l10n.theme, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          RadioGroup<int>(
            groupValue: themeIndex,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeNotifierProvider.notifier).setTheme(value);
              }
            },
            child: Column(
              children: List.generate(AppTheme.allThemes.length, (index) {
                return RadioListTile<int>(
                  title: Text(_themeName(l10n, index)),
                  value: index,
                );
              }),
            ),
          ),

          const Divider(height: 32),

          // ── Window Section (Linux desktop only) ──
          if (Platform.isLinux) ...[
            Text(l10n.window, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: const Icon(Icons.window),
              title: Text(l10n.hideSystemTitleBar),
              subtitle: Text(l10n.useCustomInAppTitleBarInstead),
              value: hideTitleBar,
              onChanged: (value) async {
                await ref
                    .read(windowSettingsNotifierProvider.notifier)
                    .setHideTitleBar(value);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.restartAppForTitleBarChange)),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: Text(l10n.appDisplayName),
              subtitle: Text(appName),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _showRenameDialog(context, ref, appName),
            ),
            const Divider(height: 32),
          ],

          // ── Shelf Layout Section ──
          Text(
            l10n.shelfLayout,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.view_module_outlined),
            title: Text(l10n.entriesPerTierRow),
            subtitle: Text(
              l10n.currentRange(
                shelfEntryColumns,
                shelfEntryMinColumns,
                shelfEntryMaxColumns,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('$shelfEntryMinColumns'),
                Expanded(
                  child: Slider(
                    value: shelfEntryColumns.toDouble(),
                    min: shelfEntryMinColumns.toDouble(),
                    max: shelfEntryMaxColumns.toDouble(),
                    divisions: shelfEntryMaxColumns - shelfEntryMinColumns,
                    label: '$shelfEntryColumns',
                    onChanged: (value) {
                      ref
                          .read(shelfEntryColumnsProvider.notifier)
                          .setColumns(value.round());
                    },
                  ),
                ),
                Text('$shelfEntryMaxColumns'),
              ],
            ),
          ),

          const Divider(height: 32),

          // ── Export Section ──
          Text(l10n.export, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: Text(l10n.exportJsonBackup),
            subtitle: Text(l10n.fullBackupJson),
            onTap: () => _export(context, ref, 'json'),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: Text(l10n.exportCsv),
            subtitle: Text(l10n.spreadsheetFormat),
            onTap: () => _export(context, ref, 'csv'),
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: Text(l10n.exportPlainText),
            subtitle: Text(l10n.copiesToClipboardAndExportsTxt),
            onTap: () => _export(context, ref, 'txt'),
          ),

          const Divider(height: 32),

          // ── Import Section ──
          Text(l10n.import, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(l10n.importJsonBackup),
            subtitle: Text(l10n.restoreFromJsonFile),
            onTap: () => _import(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add_check_circle_outlined),
            title: Text(l10n.pastePlainTextList),
            subtitle: Text(l10n.pasteTextOneAnimePerLine),
            onTap: () => _importPlainText(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.speed_outlined),
            title: Text(l10n.plainTextImportConcurrency),
            subtitle: Text(
              l10n.currentRange(
                importConcurrency,
                plainTextImportMinConcurrency,
                plainTextImportMaxConcurrency,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('$plainTextImportMinConcurrency'),
                Expanded(
                  child: Slider(
                    value: importConcurrency.toDouble(),
                    min: plainTextImportMinConcurrency.toDouble(),
                    max: plainTextImportMaxConcurrency.toDouble(),
                    divisions:
                        plainTextImportMaxConcurrency -
                        plainTextImportMinConcurrency,
                    label: '$importConcurrency',
                    onChanged: (value) {
                      ref
                          .read(plainTextImportConcurrencyProvider.notifier)
                          .setConcurrency(value.round());
                    },
                  ),
                ),
                Text('$plainTextImportMaxConcurrency'),
              ],
            ),
          ),

          const Divider(height: 32),

          // ── Data Management Section ──
          Text(
            l10n.dataManagement,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l10n.redownloadImages),
            subtitle: Text(l10n.downloadPostersMissingLocalFiles),
            onTap: imageTaskState.isRunning
                ? null
                : () => _redownloadImages(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(l10n.clearLocalImages),
            subtitle: Text(l10n.removeCachedPosterFilesFromDevice),
            onTap: imageTaskState.isRunning
                ? null
                : () => _confirmClearLocalImages(context, ref),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_sweep,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.clearAllEntries,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: Text(l10n.deletesAllEntriesKeepsTiers),
            onTap: () => _confirmClearAllEntries(context, ref),
          ),
        ],
      ),
    );
  }

  String _themeName(AppLocalizations l10n, int index) {
    switch (index) {
      case 0:
        return l10n.themeBilibiliRed;
      case 1:
        return l10n.themeDark;
      case 2:
        return l10n.themePixivBlue;
      case 3:
        return l10n.themeMikuTeal;
      default:
        return l10n.themeBilibiliRed;
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _RenameAppDialog(initialName: currentName),
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      await ref.read(appNameNotifierProvider.notifier).setName(newName);
    }
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    String format,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final exportService = ref.read(exportServiceProvider);

      if (format == 'txt') {
        final text = await exportService.exportPlainText();
        final copied = await _copyToClipboard(text);

        if (Platform.isLinux) {
          final savePath = await _exportToLinuxFile(
            ref,
            format,
            l10n: l10n,
            overrideContent: text,
          );
          if (context.mounted) {
            final message = switch ((savePath, copied)) {
              (null, true) => l10n.copiedToClipboardFileExportCancelled,
              (null, false) => l10n.exportCancelled,
              (_, true) => l10n.copiedToClipboardAndExportedToPath(savePath!),
              (_, false) => l10n.exportedToPathClipboardFailed(savePath!),
            };
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
          return;
        }

        await exportService.exportPlainTextFile(content: text);
        if (context.mounted) {
          final message = copied
              ? l10n.copiedToClipboardAndExported
              : l10n.exportCompleteClipboardFailed;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
        return;
      }

      if (Platform.isLinux) {
        final savePath = await _exportToLinuxFile(ref, format, l10n: l10n);
        if (context.mounted) {
          if (savePath == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.exportCancelled)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.exportedToPath(savePath))),
            );
          }
        }
        return;
      }

      switch (format) {
        case 'json':
          await exportService.exportJsonFile();
        case 'csv':
          await exportService.exportCsvFile();
        case 'txt':
          await exportService.exportPlainTextFile();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportComplete)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))),
        );
      }
    }
  }

  Future<String?> _exportToLinuxFile(
    WidgetRef ref,
    String format, {
    required AppLocalizations l10n,
    String? overrideContent,
  }) async {
    final exportService = ref.read(exportServiceProvider);
    late final String content;
    late final String fileName;
    late final String extension;

    switch (format) {
      case 'json':
        final data = await exportService.exportJson();
        content = const JsonEncoder.withIndent('  ').convert(data);
        fileName = 'animeshelf_backup.json';
        extension = 'json';
      case 'csv':
        content = await exportService.exportCsv();
        fileName = 'animeshelf_export.csv';
        extension = 'csv';
      case 'txt':
        content = overrideContent ?? await exportService.exportPlainText();
        fileName = 'animeshelf_export.txt';
        extension = 'txt';
      default:
        throw ArgumentError(l10n.unsupportedExportFormat(format));
    }

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: l10n.saveExportFile,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [extension],
    );

    if (savePath == null || savePath.isEmpty) {
      return null;
    }

    final file = File(savePath);
    await file.writeAsString(content);
    return file.path;
  }

  Future<bool> _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'animeshelf'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      final exportService = ref.read(exportServiceProvider);

      if (context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.importBackupQuestion),
            content: Text(l10n.importBackupWarning),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.import),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await exportService.importJson(content);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.importComplete)));
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _importPlainText(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final content = await _showPlainTextInputDialog(context);
      if (content == null) {
        return;
      }

      if (content.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.inputIsEmpty)));
        }
        return;
      }

      final started = ref
          .read(plainTextImportTaskProvider.notifier)
          .startImport(content);

      if (!started) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.plainTextImportAlreadyRunning)),
          );
        }
        return;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importFailed(e.toString()))),
        );
      }
    }
  }

  Future<String?> _showPlainTextInputDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => const _PlainTextInputDialog(),
    );
  }

  Future<void> _confirmClearAllEntries(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllEntriesQuestion),
        content: Text(l10n.clearAllEntriesWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(shelfRepositoryProvider).deleteAllEntries();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.allEntriesCleared)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToClearEntries(e.toString()))),
        );
      }
    }
  }

  Future<void> _showPlainTextImportReport(
    BuildContext context,
    PlainTextImportReport report,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final message = _buildPlainTextImportReportText(report);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.plainTextImportReportTitle),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(child: SelectableText(message)),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  String _buildPlainTextImportReportText(PlainTextImportReport report) {
    return buildPlainTextImportReportText(report);
  }

  void _redownloadImages(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final started = ref
        .read(imageRedownloadTaskProvider.notifier)
        .startRedownload();

    if (!started) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.imageDownloadAlreadyRunning)));
    }
  }

  Future<void> _confirmClearLocalImages(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearLocalImagesQuestion),
        content: Text(l10n.clearLocalImagesWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      final imageService = ref.read(localImageServiceProvider);
      final freedBytes = await imageService.clearAllLocalImages();
      final freedMb = (freedBytes / (1024 * 1024)).toStringAsFixed(1);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clearedImagesFreedMb(freedMb))),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToClearImages(e.toString()))),
        );
      }
    }
  }
}

class _RenameAppDialog extends StatefulWidget {
  final String initialName;

  const _RenameAppDialog({required this.initialName});

  @override
  State<_RenameAppDialog> createState() => _RenameAppDialogState();
}

class _RenameAppDialogState extends State<_RenameAppDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.appDisplayName),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.name,
          hintText: l10n.appNameHint,
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _PlainTextInputDialog extends StatefulWidget {
  const _PlainTextInputDialog();

  @override
  State<_PlainTextInputDialog> createState() => _PlainTextInputDialogState();
}

class _PlainTextInputDialogState extends State<_PlainTextInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.pastePlainTextList),
      content: SizedBox(
        width: 560,
        child: TextField(
          controller: _controller,
          autofocus: true,
          minLines: 12,
          maxLines: 20,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
            hintText: l10n.plainTextInputHint,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.import),
        ),
      ],
    );
  }
}

class _PlainTextImportBottomSheet extends StatelessWidget {
  final PlainTextImportTaskState state;
  final VoidCallback onCancel;
  final VoidCallback onClose;
  final VoidCallback? onViewReport;

  const _PlainTextImportBottomSheet({
    required this.state,
    required this.onCancel,
    required this.onClose,
    required this.onViewReport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final report = state.report;
    final progress = state.progress;

    final totalEntries = progress?.totalEntries ?? report?.totalEntries ?? 0;
    final processedEntries =
        progress?.processedEntries ?? report?.processedEntries ?? 0;
    final importedCount = progress?.importedCount ?? report?.importedCount ?? 0;
    final failedCount =
        progress?.failedCount ??
        ((report?.duplicateSkipped ?? 0) +
            (report?.noResultSkipped ?? 0) +
            (report?.lowConfidenceSkipped ?? 0));

    var progressValue =
        progress?.progress ??
        (totalEntries == 0 ? 0.0 : (processedEntries / totalEntries));
    progressValue = progressValue.clamp(0.0, 1.0).toDouble();
    if (!state.isRunning && report != null && !report.cancelled) {
      progressValue = 1.0;
    }

    final title = _statusText(l10n, state);

    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progressValue),
              const SizedBox(height: 8),
              Text(
                l10n.processedImportedSkipped(
                  processedEntries,
                  totalEntries,
                  importedCount,
                  failedCount,
                ),
              ),
              if (progress != null && progress.currentItem.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.currentItem(progress.currentItem),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (state.canCancel)
                    TextButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close),
                      label: Text(l10n.cancelImport),
                    ),
                  if (onViewReport != null)
                    OutlinedButton.icon(
                      onPressed: onViewReport,
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: Text(l10n.viewReport),
                    ),
                  if (!state.isRunning)
                    FilledButton.icon(
                      onPressed: onClose,
                      icon: const Icon(Icons.done),
                      label: Text(l10n.close),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(
    AppLocalizations l10n,
    PlainTextImportTaskState taskState,
  ) {
    switch (taskState.status) {
      case PlainTextImportTaskStatus.idle:
        return l10n.importIdle;
      case PlainTextImportTaskStatus.running:
        final stage = taskState.progress?.stage;
        if (stage == PlainTextImportStage.searching) {
          return l10n.searchingBangumi;
        }
        if (stage == PlainTextImportStage.importing) {
          return l10n.importingEntries;
        }
        return l10n.preparingImport;
      case PlainTextImportTaskStatus.cancelling:
        return l10n.cancellingImport;
      case PlainTextImportTaskStatus.completed:
        return taskState.report?.cancelled == true
            ? l10n.importCancelled
            : l10n.importCompleted;
      case PlainTextImportTaskStatus.failed:
        return l10n.importFailedStatus;
    }
  }
}

class _ImageTaskBottomSheet extends StatelessWidget {
  final ImageTaskState state;
  final VoidCallback onClose;

  const _ImageTaskBottomSheet({required this.state, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = switch (state.status) {
      ImageTaskStatus.idle => l10n.idle,
      ImageTaskStatus.running => l10n.downloadingImages,
      ImageTaskStatus.completed => l10n.downloadCompleteProgress(
        state.succeeded,
        state.total,
      ),
      ImageTaskStatus.failed => l10n.downloadFailed,
    };

    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: state.progress),
              const SizedBox(height: 8),
              Text(
                l10n.processedSucceeded(
                  state.processed,
                  state.total,
                  state.succeeded,
                ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 8),
              if (!state.isRunning)
                FilledButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.done),
                  label: Text(l10n.close),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
