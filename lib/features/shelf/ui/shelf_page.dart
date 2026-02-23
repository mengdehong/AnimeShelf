import 'package:anime_shelf/core/theme/app_theme.dart';
import 'package:anime_shelf/core/utils/rank_utils.dart';
import 'package:anime_shelf/core/window/fused_app_bar.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:anime_shelf/features/shelf/ui/tier_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Main shelf page — displays all tiers with their entries.
///
/// Supports drag-and-drop reordering of both tiers and entries.
class ShelfPage extends HookConsumerWidget {
  const ShelfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiersAsync = ref.watch(shelfTiersProvider);

    return Scaffold(
      appBar: FusedAppBar(
        showAppName: true,
        titleSpacing: 12,
        title: _SearchBar(onTap: () => context.push('/search')),
        actions: [
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
      body: tiersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load shelf',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(error.toString()),
            ],
          ),
        ),
        data: (tiers) => _ShelfContent(tiers: tiers),
      ),
    );
  }

  void _showAddTierDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emojiController = TextEditingController();
    var selectedColor = 0xFF2196F3;

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
            Text('New Tier', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. S, A, B, C...',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emojiController,
              decoration: const InputDecoration(
                labelText: 'Emoji (optional)',
                hintText: 'e.g. \u{1F451}',
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
              child: const Text('Add Tier'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inner scrollable content showing all tier sections.
class _ShelfContent extends HookConsumerWidget {
  final List<TierWithEntries> tiers;

  const _ShelfContent({required this.tiers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tiers.isEmpty) {
      return const Center(child: Text('No tiers yet. Tap + to add one.'));
    }

    final metrics = Theme.of(context).extension<AppThemeMetrics>();
    final sectionRadius = metrics?.sectionRadius ?? 16;

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      buildDefaultDragHandles: false,
      cacheExtent: 600,
      itemCount: tiers.length,
      onReorder: (oldIndex, newIndex) =>
          _onReorderTier(ref, oldIndex, newIndex),
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(sectionRadius),
            child: child,
          ),
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final tierData = tiers[index];
        return RepaintBoundary(
          key: ValueKey(tierData.tier.id),
          child: TierSection(index: index, tierData: tierData, allTiers: tiers),
        );
      },
    );
  }

  void _onReorderTier(WidgetRef ref, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    if (oldIndex == newIndex) {
      return;
    }

    final tier = tiers[oldIndex].tier;

    // Calculate the actual prev/next based on movement direction
    final double? actualPrev;
    final double? actualNext;
    if (oldIndex < newIndex) {
      actualPrev = tiers[newIndex].tier.tierSort;
      actualNext = newIndex + 1 < tiers.length
          ? tiers[newIndex + 1].tier.tierSort
          : null;
    } else {
      actualPrev = newIndex > 0 ? tiers[newIndex - 1].tier.tierSort : null;
      actualNext = tiers[newIndex].tier.tierSort;
    }

    final newSort = RankUtils.insertRank(actualPrev, actualNext);
    final repo = ref.read(shelfRepositoryProvider);
    repo.reorderTier(tierId: tier.id, newSort: newSort);

    if (actualPrev != null &&
        actualNext != null &&
        RankUtils.needsRecompression(actualPrev, actualNext)) {
      repo.recompressTierSorts();
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
              'Search Bangumi...',
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
