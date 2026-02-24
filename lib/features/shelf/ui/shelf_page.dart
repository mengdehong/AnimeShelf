import 'package:anime_shelf/core/utils/export_service.dart';
import 'package:anime_shelf/core/utils/plain_text_import_report_formatter.dart';
import 'package:anime_shelf/core/window/fused_app_bar.dart';
import 'package:anime_shelf/features/settings/providers/settings_provider.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:anime_shelf/features/shelf/ui/tier_section.dart';
import 'package:anime_shelf/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Main shelf page — displays all tiers with their entries.
///
/// Supports drag-and-drop for entries.
/// Tier ordering is managed from a dedicated bottom sheet.
class ShelfPage extends HookConsumerWidget {
  const ShelfPage({super.key});

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
            onPressed: loadedTiers == null
                ? null
                : () => _showManageTierOrderSheet(context, ref, loadedTiers),
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

  Future<void> _showManageTierOrderSheet(
    BuildContext context,
    WidgetRef ref,
    List<TierWithEntries> tiers,
  ) async {
    final repository = ref.read(shelfRepositoryProvider);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return _ManageTierOrderSheet(tiers: tiers, repository: repository);
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
  final ShelfRepository repository;

  const _ManageTierOrderSheet({required this.tiers, required this.repository});

  @override
  State<_ManageTierOrderSheet> createState() => _ManageTierOrderSheetState();
}

sealed class _ManagedTierListItem {
  const _ManagedTierListItem();

  String get itemKey;
  String get name;
  String get emoji;
  int get colorValue;
  bool get isInbox;
}

class _ExistingManagedTierItem extends _ManagedTierListItem {
  final TierWithEntries tierData;

  const _ExistingManagedTierItem(this.tierData);

  @override
  String get itemKey => 'existing-${tierData.tier.id}';

  @override
  String get name => tierData.tier.name;

  @override
  String get emoji => tierData.tier.emoji;

  @override
  int get colorValue => tierData.tier.colorValue;

  @override
  bool get isInbox => tierData.tier.isInbox;

  int get tierId => tierData.tier.id;
}

class _PendingManagedTierItem extends _ManagedTierListItem {
  final int localId;

  @override
  final String name;

  @override
  final String emoji;

  @override
  final int colorValue;

  const _PendingManagedTierItem({
    required this.localId,
    required this.name,
    required this.emoji,
    required this.colorValue,
  });

  @override
  String get itemKey => 'pending-$localId';

  @override
  bool get isInbox => false;
}

class _ManageTierOrderSheetState extends State<_ManageTierOrderSheet> {
  static const _colorOptions = <int>[
    0xFFFFD700,
    0xFFFF6B6B,
    0xFF4ECDC4,
    0xFF45B7D1,
    0xFFFFA07A,
    0xFF98D8C8,
    0xFFB19CD9,
    0xFFFF69B4,
  ];

  late final List<_ManagedTierListItem> _orderedTiers;
  late final List<int> _initialExistingTierOrder;
  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;
  final ScrollController _listScrollController = ScrollController();
  var _isSaving = false;
  var _isAddingTier = false;
  var _pendingIdSeed = 0;
  var _selectedColor = _colorOptions.first;

  @override
  void initState() {
    super.initState();
    _orderedTiers = widget.tiers
        .map<_ManagedTierListItem>(
          (tierData) => _ExistingManagedTierItem(tierData),
        )
        .toList(growable: true);
    _initialExistingTierOrder = _orderedTiers
        .whereType<_ExistingManagedTierItem>()
        .map((item) => item.tierId)
        .toList(growable: false);
    _nameController = TextEditingController();
    _emojiController = TextEditingController();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = !_isSaving && !_isAddingTier && _hasPersistedChanges;

    return PopScope(
      canPop: !_isSaving && !_hasUnsavedChanges,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Manage Tiers',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isSaving || _isAddingTier
                          ? null
                          : _startAddTier,
                      icon: const Icon(Icons.add),
                      label: const Text('New Tier'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Drag tiers to reorder them or add a new tier. '
                  'Changes apply when you save.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                if (_isAddingTier) ...[
                  _buildAddTierCard(context),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: ReorderableListView.builder(
                    scrollController: _listScrollController,
                    itemCount: _orderedTiers.length,
                    buildDefaultDragHandles: false,
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final item = _orderedTiers[index];
                      final title = item.emoji.isEmpty
                          ? item.name
                          : '${item.emoji} ${item.name}';

                      return ListTile(
                        key: ValueKey(item.itemKey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(item.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(title),
                        subtitle: Text(_tierSubtitle(item)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item is _PendingManagedTierItem)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'New',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                      ),
                                ),
                              ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_indicator),
                            ),
                          ],
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
                      onPressed: _isSaving ? null : _handleCancel,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: canSave ? _save : null,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddTierCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New Tier', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.name,
              hintText: l10n.tierNameHint,
            ),
            autofocus: true,
            textInputAction: TextInputAction.next,
            enabled: !_isSaving,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _emojiController,
            decoration: InputDecoration(
              labelText: l10n.emojiOptional,
              hintText: l10n.emojiHint,
            ),
            enabled: !_isSaving,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorOptions
                .map((colorValue) {
                  final isSelected = _selectedColor == colorValue;

                  return InkWell(
                    onTap: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _selectedColor = colorValue;
                            });
                          },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onSurface
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSaving ? null : _cancelAddTier,
                child: const Text('Cancel Add'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isSaving ? null : _addPendingTier,
                child: const Text('Add to List'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _tierSubtitle(_ManagedTierListItem item) {
    if (item is _PendingManagedTierItem) {
      return 'New tier (unsaved)';
    }
    if (item.isInbox) {
      return 'Inbox tier';
    }
    return 'Custom tier';
  }

  Future<void> _handleCancel() async {
    final shouldClose = await _confirmDiscardChanges();
    if (!mounted || !shouldClose) {
      return;
    }
    Navigator.of(context).pop();
  }

  void _onPopInvokedWithResult(bool didPop, Object? result) {
    if (didPop || _isSaving) {
      return;
    }
    _handleCancel();
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final shouldDiscard =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text(
              'You have unsaved tier changes. Discard them and close?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep Editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;

    return shouldDiscard;
  }

  bool get _hasPendingTiers {
    return _orderedTiers.any((item) => item is _PendingManagedTierItem);
  }

  bool get _hasReorderedExistingTiers {
    final currentExistingOrder = _orderedTiers
        .whereType<_ExistingManagedTierItem>()
        .map((item) => item.tierId)
        .toList(growable: false);
    return !listEquals(currentExistingOrder, _initialExistingTierOrder);
  }

  bool get _hasDraftInput {
    if (!_isAddingTier) {
      return false;
    }
    return _nameController.text.trim().isNotEmpty ||
        _emojiController.text.trim().isNotEmpty;
  }

  bool get _hasPersistedChanges {
    return _hasPendingTiers || _hasReorderedExistingTiers;
  }

  bool get _hasUnsavedChanges {
    return _hasPersistedChanges || _hasDraftInput;
  }

  void _startAddTier() {
    setState(() {
      _isAddingTier = true;
      _selectedColor = _colorOptions.first;
      _nameController.clear();
      _emojiController.clear();
    });
  }

  void _cancelAddTier() {
    setState(() {
      _isAddingTier = false;
      _nameController.clear();
      _emojiController.clear();
      _selectedColor = _colorOptions.first;
    });
  }

  void _addPendingTier() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tier name is required')));
      return;
    }

    final pendingItem = _PendingManagedTierItem(
      localId: _pendingIdSeed,
      name: name,
      emoji: _emojiController.text.trim(),
      colorValue: _selectedColor,
    );

    setState(() {
      _pendingIdSeed += 1;
      _orderedTiers.add(pendingItem);
      _isAddingTier = false;
      _nameController.clear();
      _emojiController.clear();
      _selectedColor = _colorOptions.first;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listScrollController.hasClients) {
        return;
      }
      _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
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
      await widget.repository.saveTierManagementChanges(
        _orderedTiers
            .map((item) {
              if (item is _ExistingManagedTierItem) {
                return TierManagementItem.existing(tierId: item.tierId);
              }
              final pending = item as _PendingManagedTierItem;
              return TierManagementItem.pending(
                pendingTier: PendingTierDraft(
                  name: pending.name,
                  emoji: pending.emoji,
                  colorValue: pending.colorValue,
                ),
              );
            })
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
        const SnackBar(content: Text('Failed to save tier changes')),
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
