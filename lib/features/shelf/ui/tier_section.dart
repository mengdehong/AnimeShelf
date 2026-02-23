import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/theme/app_theme.dart';
import 'package:anime_shelf/core/utils/rank_utils.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:anime_shelf/features/shelf/ui/entry_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A single tier section on the shelf — header + grid of entry cards.
///
/// The section itself is a [DragTarget] for entries being dragged
/// across tiers. The header shows tier name, emoji, color, and actions.
class TierSection extends HookConsumerWidget {
  final int index;
  final TierWithEntries tierData;
  final List<TierWithEntries> allTiers;

  const TierSection({
    super.key,
    required this.index,
    required this.tierData,
    required this.allTiers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = tierData.tier;
    final entries = tierData.entries;
    final tierColor = Color(tier.colorValue);
    final theme = Theme.of(context);
    final metrics = theme.extension<AppThemeMetrics>();
    final sectionRadius = metrics?.sectionRadius ?? 16;
    final posterRadius = metrics?.posterRadius ?? 12;
    final cardColor = theme.cardTheme.color;

    return DragTarget<_EntryDragData>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        // Only append to the end if it's coming from a different tier.
        // If it's from the same tier and drops on the general background,
        // we ignore it to prevent accidental sorting to the end.
        if (details.data.sourceTierId == tierData.tier.id) return;
        _handleDrop(ref, details.data, entries.length);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isHovering ? tierColor.withValues(alpha: 0.12) : cardColor,
            borderRadius: BorderRadius.circular(sectionRadius),
            border: isHovering ? Border.all(color: tierColor, width: 2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DragTarget<_EntryDragData>(
                onWillAcceptWithDetails: (details) =>
                    details.data.sourceTierId != tierData.tier.id ||
                    entries.isNotEmpty &&
                        details.data.entryId != entries.first.entry.id,
                onAcceptWithDetails: (details) {
                  _handleDrop(ref, details.data, 0);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHoveringHeader = candidateData.isNotEmpty;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isHoveringHeader
                          ? tierColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(sectionRadius),
                        topRight: Radius.circular(sectionRadius),
                      ),
                    ),
                    child: _TierHeader(
                      index: index,
                      tier: tier,
                      tierColor: tierColor,
                      onEdit: () => _showEditDialog(context, ref),
                    ),
                  );
                },
              ),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Center(
                    child: Text(
                      tier.isInbox
                          ? 'Search and add anime to get started'
                          : 'Drag entries here',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: entries.asMap().entries.map((e) {
                      final index = e.key;
                      final entryData = e.value;
                      return _buildDraggableEntry(
                        context,
                        ref,
                        entryData,
                        index,
                        entries,
                        posterRadius,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableEntry(
    BuildContext context,
    WidgetRef ref,
    EntryWithSubject entryData,
    int index,
    List<EntryWithSubject> entries,
    double posterRadius,
  ) {
    final dragData = _EntryDragData(
      entryId: entryData.entry.id,
      sourceTierId: tierData.tier.id,
    );

    return LongPressDraggable<_EntryDragData>(
      data: dragData,
      delay: const Duration(milliseconds: 300),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(posterRadius),
        child: Opacity(
          opacity: 0.85,
          child: _EntryCardBox(entryData: entryData, onTap: () {}),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _EntryCardBox(entryData: entryData, onTap: () {}),
      ),
      child: DragTarget<_EntryDragData>(
        onWillAcceptWithDetails: (details) => true,
        onAcceptWithDetails: (details) {
          if (details.data.entryId == entryData.entry.id) return;
          _handleDrop(ref, details.data, index);
        },
        builder: (context, candidateData, rejectedData) {
          return _EntryCardBox(
            entryData: entryData,
            onTap: () => context.push('/details/${entryData.entry.id}'),
          );
        },
      ),
    );
  }

  void _handleDrop(WidgetRef ref, _EntryDragData data, int targetIndex) {
    final entries = tierData.entries;

    // Adjust the target index if we are moving the item backwards within the same tier
    int adjustedIndex = targetIndex;
    if (data.sourceTierId == tierData.tier.id && targetIndex < entries.length) {
      final sourceIndex = entries.indexWhere((e) => e.entry.id == data.entryId);
      if (sourceIndex != -1 && sourceIndex < targetIndex) {
        adjustedIndex = targetIndex + 1;
      }
    }

    final double? prev = adjustedIndex > 0
        ? entries[adjustedIndex - 1].entry.entryRank
        : null;
    final double? next = adjustedIndex < entries.length
        ? entries[adjustedIndex].entry.entryRank
        : null;

    final newRank = RankUtils.insertRank(prev, next);
    final repo = ref.read(shelfRepositoryProvider);

    repo.moveEntry(
      entryId: data.entryId,
      targetTierId: tierData.tier.id,
      newRank: newRank,
    );

    if (prev != null &&
        next != null &&
        RankUtils.needsRecompression(prev, next)) {
      repo.recompressEntryRanks(tierData.tier.id);
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final tier = tierData.tier;
    final nameController = TextEditingController(text: tier.name);
    final emojiController = TextEditingController(text: tier.emoji);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Tier',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (!tier.isInbox)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _confirmDelete(context, ref);
                    },
                    tooltip: 'Delete Tier',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emojiController,
              decoration: const InputDecoration(labelText: 'Emoji'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                ref
                    .read(shelfRepositoryProvider)
                    .updateTier(
                      tierId: tier.id,
                      name: nameController.text.trim(),
                      emoji: emojiController.text.trim(),
                    );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tier?'),
        content: Text(
          'Entries in "${tierData.tier.name}" will be moved to Inbox.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(shelfRepositoryProvider).deleteTier(tierData.tier.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Tier header row with name, emoji, color chip, and action buttons.
class _TierHeader extends StatelessWidget {
  final int index;
  final Tier tier;
  final Color tierColor;
  final VoidCallback onEdit;

  const _TierHeader({
    required this.index,
    required this.tier,
    required this.tierColor,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: ReorderableDragStartListener(
              index: index,
              child: GestureDetector(
                onDoubleTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: tierColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (tier.emoji.isNotEmpty) ...[
                      Text(tier.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        tier.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCardBox extends StatelessWidget {
  const _EntryCardBox({required this.entryData, required this.onTap});

  final EntryWithSubject entryData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 160,
      child: RepaintBoundary(
        child: EntryCard(entryData: entryData, onTap: onTap),
      ),
    );
  }
}

/// Internal data carried during drag-and-drop.
class _EntryDragData {
  final int entryId;
  final int sourceTierId;

  const _EntryDragData({required this.entryId, required this.sourceTierId});
}
