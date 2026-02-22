import 'dart:io';

import 'package:anime_shelf/core/theme/app_theme.dart';
import 'package:anime_shelf/core/theme/theme_notifier.dart';
import 'package:anime_shelf/core/window/window_settings_notifier.dart';
import 'package:anime_shelf/features/settings/providers/settings_provider.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
        ],
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    String format,
  ) async {
    try {
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
}
