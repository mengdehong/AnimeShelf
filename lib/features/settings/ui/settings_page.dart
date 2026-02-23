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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Settings page — theme switching, backup/export, and import.
class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeIndex = ref.watch(themeNotifierProvider);
    final hideTitleBar = ref.watch(windowSettingsNotifierProvider);
    final appName = ref.watch(appNameNotifierProvider);
    final importTaskState = ref.watch(plainTextImportTaskProvider);
    final importConcurrency = ref.watch(plainTextImportConcurrencyProvider);
    final imageTaskState = ref.watch(imageRedownloadTaskProvider);

    // Pick whichever bottom sheet is active (import takes priority).
    final showImportPanel = importTaskState.showPanel;
    final showImagePanel = !showImportPanel && imageTaskState.showPanel;
    final hasBottomPanel = showImportPanel || showImagePanel;

    return Scaffold(
      appBar: const FusedAppBar(title: Text('Settings')),
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
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          RadioGroup<int>(
            groupValue: themeIndex,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeNotifierProvider.notifier).setTheme(value);
              }
            },
            child: Column(
              children: List.generate(AppTheme.themeNames.length, (index) {
                return RadioListTile<int>(
                  title: Text(AppTheme.themeNames[index]),
                  value: index,
                );
              }),
            ),
          ),

          const Divider(height: 32),

          // ── Window Section (Linux desktop only) ──
          if (Platform.isLinux) ...[
            Text('Window', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SwitchListTile(
              secondary: const Icon(Icons.window),
              title: const Text('Hide system title bar'),
              subtitle: const Text('Use a custom in-app title bar instead'),
              value: hideTitleBar,
              onChanged: (value) async {
                await ref
                    .read(windowSettingsNotifierProvider.notifier)
                    .setHideTitleBar(value);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Restart the app for this change to fully take effect.',
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('App display name'),
              subtitle: Text(appName),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _showRenameDialog(context, ref, appName),
            ),
            const Divider(height: 32),
          ],

          // ── Export Section ──
          Text('Export', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Export JSON Backup'),
            subtitle: const Text('Full backup (.json)'),
            onTap: () => _export(context, ref, 'json'),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export CSV'),
            subtitle: const Text('Spreadsheet format'),
            onTap: () => _export(context, ref, 'csv'),
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Export Markdown'),
            subtitle: const Text('Blog-ready format'),
            onTap: () => _export(context, ref, 'md'),
          ),

          const Divider(height: 32),

          // ── Import Section ──
          Text('Import', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import JSON Backup'),
            subtitle: const Text('Restore from .json file'),
            onTap: () => _import(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add_check_circle_outlined),
            title: const Text('Paste Plain Text List'),
            subtitle: const Text('Paste text; one anime per line'),
            onTap: () => _importPlainText(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.speed_outlined),
            title: const Text('Plain Text Import Concurrency'),
            subtitle: Text(
              'Current: $importConcurrency '
              '(range $plainTextImportMinConcurrency-'
              '$plainTextImportMaxConcurrency)',
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
            'Data Management',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Re-download Images'),
            subtitle: const Text(
              'Download posters for entries missing local files',
            ),
            onTap: imageTaskState.isRunning
                ? null
                : () => _redownloadImages(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear Local Images'),
            subtitle: const Text('Remove all cached poster files from device'),
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
              'Clear All Entries',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Deletes all entries; keeps tiers intact'),
            onTap: () => _confirmClearAllEntries(context, ref),
          ),
        ],
      ),
    );
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
    try {
      if (Platform.isLinux) {
        final savePath = await _exportToLinuxFile(ref, format);
        if (context.mounted) {
          if (savePath == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Export cancelled')));
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Exported to $savePath')));
          }
        }
        return;
      }

      final exportService = ref.read(exportServiceProvider);
      switch (format) {
        case 'json':
          await exportService.exportJsonFile();
        case 'csv':
          await exportService.exportCsvFile();
        case 'md':
          await exportService.exportMarkdownFile();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export complete')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<String?> _exportToLinuxFile(WidgetRef ref, String format) async {
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
      case 'md':
        content = await exportService.exportMarkdown();
        fileName = 'animeshelf_export.md';
        extension = 'md';
      default:
        throw ArgumentError('Unsupported export format: $format');
    }

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save export file',
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

  Future<void> _import(BuildContext context, WidgetRef ref) async {
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
            title: const Text('Import Backup?'),
            content: const Text(
              'This will replace all current data. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Import'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await exportService.importJson(content);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Import complete')));
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  Future<void> _importPlainText(BuildContext context, WidgetRef ref) async {
    try {
      final content = await _showPlainTextInputDialog(context);
      if (content == null) {
        return;
      }

      if (content.trim().isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Input is empty')));
        }
        return;
      }

      if (context.mounted) {
        final started = ref
            .read(plainTextImportTaskProvider.notifier)
            .startImport(content);

        if (!started) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plain text import is already running'),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import started in background')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Entries?'),
        content: const Text(
          'This will permanently delete all entries from your shelf. '
          'Your custom tiers will not be deleted.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
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
        ).showSnackBar(const SnackBar(content: Text('All entries cleared')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to clear entries: $e')));
      }
    }
  }

  Future<void> _showPlainTextImportReport(
    BuildContext context,
    PlainTextImportReport report,
  ) async {
    final message = _buildPlainTextImportReportText(report);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('纯文本导入报告'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(child: SelectableText(message)),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _buildPlainTextImportReportText(PlainTextImportReport report) {
    return buildPlainTextImportReportText(report);
  }

  void _redownloadImages(BuildContext context, WidgetRef ref) {
    final started = ref
        .read(imageRedownloadTaskProvider.notifier)
        .startRedownload();

    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image download is already running')),
      );
    }
  }

  Future<void> _confirmClearLocalImages(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Images?'),
        content: const Text(
          'This will delete all locally cached poster images. '
          'Network URLs are preserved; images can be re-downloaded later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
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
          SnackBar(content: Text('Cleared images ($freedMb MB freed)')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to clear images: $e')));
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
    return AlertDialog(
      title: const Text('App display name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Name',
          hintText: 'AnimeShelf',
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Save'),
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
    return AlertDialog(
      title: const Text('Paste Plain Text List'),
      content: SizedBox(
        width: 560,
        child: TextField(
          controller: _controller,
          autofocus: true,
          minLines: 12,
          maxLines: 20,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
            hintText: 'S\nClannad\n\nA\n欢迎加入NHK',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Import'),
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

    final title = _statusText(state);

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
                'Processed: $processedEntries/$totalEntries  '
                'Imported: $importedCount  '
                'Skipped: $failedCount',
              ),
              if (progress != null && progress.currentItem.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Current: ${progress.currentItem}',
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
                      label: const Text('Cancel Import'),
                    ),
                  if (onViewReport != null)
                    OutlinedButton.icon(
                      onPressed: onViewReport,
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('View Report'),
                    ),
                  if (!state.isRunning)
                    FilledButton.icon(
                      onPressed: onClose,
                      icon: const Icon(Icons.done),
                      label: const Text('Close'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(PlainTextImportTaskState taskState) {
    switch (taskState.status) {
      case PlainTextImportTaskStatus.idle:
        return 'Import idle';
      case PlainTextImportTaskStatus.running:
        final stage = taskState.progress?.stage;
        if (stage == PlainTextImportStage.searching) {
          return 'Searching Bangumi...';
        }
        if (stage == PlainTextImportStage.importing) {
          return 'Importing entries...';
        }
        return 'Preparing import...';
      case PlainTextImportTaskStatus.cancelling:
        return 'Cancelling import...';
      case PlainTextImportTaskStatus.completed:
        return taskState.report?.cancelled == true
            ? 'Import cancelled'
            : 'Import completed';
      case PlainTextImportTaskStatus.failed:
        return 'Import failed';
    }
  }
}

class _ImageTaskBottomSheet extends StatelessWidget {
  final ImageTaskState state;
  final VoidCallback onClose;

  const _ImageTaskBottomSheet({required this.state, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final title = switch (state.status) {
      ImageTaskStatus.idle => 'Idle',
      ImageTaskStatus.running => 'Downloading images...',
      ImageTaskStatus.completed =>
        'Download complete (${state.succeeded}/${state.total})',
      ImageTaskStatus.failed => 'Download failed',
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
                'Processed: ${state.processed}/${state.total}  '
                'Succeeded: ${state.succeeded}',
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
                  label: const Text('Close'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
