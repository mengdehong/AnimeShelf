import 'package:anime_shelf/core/utils/export_service.dart';
import 'package:anime_shelf/core/utils/plain_text_import_report_formatter.dart';
import 'package:anime_shelf/core/window/fused_app_bar.dart';
import 'package:anime_shelf/features/settings/providers/settings_provider.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:anime_shelf/features/shelf/ui/tier_section.dart';
import 'package:anime_shelf/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Main shelf page — displays all tiers with their entries.
///
/// Supports drag-and-drop for entries.
/// Tier ordering is managed from a dedicated bottom sheet.
class ShelfPage extends HookConsumerWidget {
  const ShelfPage({super.key});

  static const _addTierSheetAnimationStyle = AnimationStyle(
    duration: Duration(milliseconds: 100),
    reverseDuration: Duration(milliseconds: 90),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiersAsync = ref.watch(shelfTiersProvider);
    final importTaskState = ref.watch(plainTextImportTaskProvider);
    final l10n = AppLocalizations.of(context)!;
    final loadedTiers = tiersAsync.valueOrNull;

    return Scaffold(
      appBar: FusedAppBar(
        showAppName: true,
        titleSpacing: 12,
        title: _SearchBar(onTap: () => context.push('/search')),
        actions: [
          IconButton(
            icon: const Icon(Icons.reorder),
            tooltip: 'Manage Tier Order',
            onPressed: loadedTiers == null || loadedTiers.length < 2
                ? null
                : () => _showManageTierOrderSheet(context, ref, loadedTiers),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTierDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      bottomSheet: importTaskState.showPanel
          ? _ShelfImportProgressPanel(
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
          : null,
      body: tiersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.failedToLoadShelf,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(error.toString()),
            ],
          ),
        ),
        data: (tiers) => _ShelfContent(
          tiers: tiers,
          bottomPadding: importTaskState.showPanel ? 180 : 16,
        ),
      ),
    );
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

  Future<void> _showAddTierDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final emojiController = TextEditingController();
    var selectedColor = 0xFF2196F3;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        sheetAnimationStyle: _addTierSheetAnimationStyle,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.newTier,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  hintText: l10n.tierNameHint,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emojiController,
                decoration: InputDecoration(
                  labelText: l10n.emojiOptional,
                  hintText: l10n.emojiHint,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children:
                    [
                      0xFFFFD700,
                      0xFFFF6B6B,
                      0xFF4ECDC4,
                      0xFF45B7D1,
                      0xFFFFA07A,
                      0xFF98D8C8,
                      0xFFB19CD9,
                      0xFFFF69B4,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () => selectedColor = color,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(color),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    return;
                  }
                  ref
                      .read(shelfRepositoryProvider)
                      .addTier(
                        name: name,
                        emoji: emojiController.text.trim(),
                        colorValue: selectedColor,
                      );
                  Navigator.of(context).pop();
                },
                child: Text(l10n.addTier),
              ),
            ],
          ),
        ),
      );
    } finally {
      nameController.dispose();
      emojiController.dispose();
    }
  }

  Future<void> _showManageTierOrderSheet(
    BuildContext context,
    WidgetRef ref,
    List<TierWithEntries> tiers,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _ManageTierOrderSheet(
          tiers: tiers,
          onSave: (orderedTierIds) {
            return ref
                .read(shelfRepositoryProvider)
                .setTierOrder(orderedTierIds);
          },
        );
      },
    );
  }
}

/// Inner scrollable content showing all tier sections.
class _ShelfContent extends StatelessWidget {
  final List<TierWithEntries> tiers;
  final double bottomPadding;

  const _ShelfContent({required this.tiers, required this.bottomPadding});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (tiers.isEmpty) {
      return Center(child: Text(l10n.noTiersYet));
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: bottomPadding),
      cacheExtent: 600,
      itemCount: tiers.length,
      itemBuilder: (context, index) {
        final tierData = tiers[index];
        return RepaintBoundary(
          key: ValueKey(tierData.tier.id),
          child: TierSection(tier: tierData.tier, entries: tierData.entries),
        );
      },
    );
  }
}

class _ManageTierOrderSheet extends StatefulWidget {
  final List<TierWithEntries> tiers;
  final Future<void> Function(List<int> orderedTierIds) onSave;

  const _ManageTierOrderSheet({required this.tiers, required this.onSave});

  @override
  State<_ManageTierOrderSheet> createState() => _ManageTierOrderSheetState();
}

class _ManageTierOrderSheetState extends State<_ManageTierOrderSheet> {
  late final List<TierWithEntries> _orderedTiers;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _orderedTiers = widget.tiers.toList(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Manage Tier Order',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Drag tiers to reorder them. This only changes section order.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: _orderedTiers.length,
                  buildDefaultDragHandles: false,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final tier = _orderedTiers[index].tier;
                    return ListTile(
                      key: ValueKey(tier.id),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(tier.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        tier.emoji.isEmpty
                            ? tier.name
                            : '${tier.emoji} ${tier.name}',
                      ),
                      subtitle: tier.isInbox
                          ? const Text('Inbox tier')
                          : const Text('Custom tier'),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_indicator),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Order'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (oldIndex == newIndex) {
      return;
    }

    setState(() {
      final moved = _orderedTiers.removeAt(oldIndex);
      _orderedTiers.insert(newIndex, moved);
    });
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(
        _orderedTiers
            .map((tierData) => tierData.tier.id)
            .toList(growable: false),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save tier order')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _ShelfImportProgressPanel extends StatelessWidget {
  final PlainTextImportTaskState state;
  final VoidCallback onCancel;
  final VoidCallback onClose;
  final VoidCallback? onViewReport;

  const _ShelfImportProgressPanel({
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

/// A pill-shaped, read-only search bar that navigates to the search page
/// on tap.  Visually mimics a text field so users intuitively know they
/// can search from here.
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.searchBangumiHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
