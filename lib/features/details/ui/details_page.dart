import 'dart:io';

import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/utils/rank_utils.dart';
import 'package:anime_shelf/core/window/window_controls.dart';
import 'package:anime_shelf/core/window/window_settings_notifier.dart';
import 'package:anime_shelf/features/details/providers/details_provider.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:anime_shelf/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Immersive detail page for an entry.
///
/// Features a large poster header, metadata display,
/// tier quick-move, tags, staff info, and a private notes editor.
class DetailsPage extends HookConsumerWidget {
  final int entryId;

  const DetailsPage({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(entryDetailProvider(entryId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(l10n.failedToLoadDetails(error.toString())),
            ],
          ),
        ),
        data: (detail) {
          if (detail == null) {
            return Center(child: Text(l10n.entryNotFound));
          }
          return _DetailsContent(
            entryId: entryId,
            entry: detail.entry,
            subject: detail.subject,
            tier: detail.tier,
          );
        },
      ),
    );
  }
}

class _DetailsContent extends HookConsumerWidget {
  final int entryId;
  final Entry entry;
  final Subject? subject;
  final Tier? tier;

  const _DetailsContent({
    required this.entryId,
    required this.entry,
    this.subject,
    this.tier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final noteController = useTextEditingController(text: entry.note);
    final localLargePath = subject?.localLargeImagePath ?? '';
    final largePosterUrl = subject?.largePosterUrl ?? '';
    final posterUrl = subject?.posterUrl ?? '';
    final title = (subject?.nameCn.isNotEmpty == true)
        ? subject!.nameCn
        : (subject?.nameJp ?? l10n.unknown);
    final originalTitle = subject?.nameJp ?? '';
    final airDate = subject?.airDate ?? '';
    final rating = subject?.rating ?? 0.0;
    final summary = subject?.summary ?? '';
    final globalRank = subject?.globalRank ?? 0;
    final tags = subject?.tags ?? '';
    final director = subject?.director ?? '';
    final studio = subject?.studio ?? '';
    final subjectId = subject?.subjectId;

    final isDesktopCustomBar =
        Platform.isLinux && ref.watch(windowSettingsNotifierProvider);

    return CustomScrollView(
      slivers: [
        // Large poster header
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.height * 0.75,
          pinned: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          actions: [
            // Open in Bangumi button
            if (subjectId != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.open_in_new),
                  tooltip: l10n.openInBangumi,
                  onPressed: () => _openBangumi(subjectId),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.removeFromShelf,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ),
            if (isDesktopCustomBar)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: WindowControls(
                  foregroundColor: Colors.white,
                  buttonBackgroundColor: Colors.black.withValues(alpha: 0.3),
                ),
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'entry-poster-$entryId',
                  child: _buildDetailPoster(
                    context,
                    localLargePath: localLargePath,
                    largePosterUrl: largePosterUrl,
                    posterUrl: posterUrl,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Metadata + Notes
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (originalTitle.isNotEmpty && originalTitle != title) ...[
                  const SizedBox(height: 6),
                  Text(
                    originalTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // All metadata chips in a single row
                _buildChipsRow(
                  context,
                  ref,
                  rating: rating,
                  globalRank: globalRank,
                  airDate: airDate,
                  createdAt: entry.createdAt,
                ),

                // Tags row
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildTagsRow(context, tags),
                ],

                // Director & Studio
                if (director.isNotEmpty || studio.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildStaffSection(context, director, studio),
                ],

                // Summary
                if (summary.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.summary,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(summary, style: Theme.of(context).textTheme.bodyMedium),
                ],

                // Notes
                const SizedBox(height: 24),
                Text(
                  l10n.privateNotes,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: null,
                  minLines: 3,
                  decoration: InputDecoration(hintText: l10n.writeThoughtsHint),
                  onChanged: (value) {
                    ref
                        .read(entryDetailProvider(entryId).notifier)
                        .updateNote(value);
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Single row of all metadata chips: tier, rating, rank, air date, createdAt.
  Widget _buildChipsRow(
    BuildContext context,
    WidgetRef ref, {
    required double rating,
    required int globalRank,
    required String airDate,
    required DateTime createdAt,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Tier chip (tappable for quick-move)
        if (tier != null)
          ActionChip(
            avatar: tier!.emoji.isNotEmpty
                ? Text(tier!.emoji, style: const TextStyle(fontSize: 14))
                : CircleAvatar(
                    backgroundColor: Color(tier!.colorValue),
                    radius: 8,
                  ),
            label: Text(tier!.name),
            backgroundColor: Color(tier!.colorValue).withValues(alpha: 0.2),
            side: BorderSide(
              color: Color(tier!.colorValue).withValues(alpha: 0.5),
            ),
            onPressed: () => _showTierMoveSheet(context, ref),
          ),
        // Bangumi score
        if (rating > 0)
          Chip(
            avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
            label: Text(rating.toStringAsFixed(1)),
          ),
        // Bangumi global rank
        if (globalRank > 0)
          Chip(
            avatar: const Icon(Icons.leaderboard, size: 16),
            label: Text('#$globalRank'),
          ),
        // Air date
        if (airDate.isNotEmpty)
          Chip(
            avatar: const Icon(Icons.calendar_today, size: 16),
            label: Text(airDate),
          ),
        // Added to shelf date
        Chip(
          avatar: const Icon(Icons.add_circle_outline, size: 16),
          label: Text(_formatDate(createdAt)),
        ),
      ],
    );
  }

  /// Shows a bottom sheet to move the entry to a different tier.
  void _showTierMoveSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) =>
          _TierMoveSheet(entryId: entryId, currentTierId: entry.tierId),
    );
  }

  /// Row of tag chips.
  Widget _buildTagsRow(BuildContext context, String tags) {
    final tagList = tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (tagList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tagList
          .map(
            (tag) => Chip(
              label: Text(tag),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(),
    );
  }

  /// Staff section showing director and studio.
  Widget _buildStaffSection(
    BuildContext context,
    String director,
    String studio,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.staff, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (director.isNotEmpty)
          _buildStaffRow(context, Icons.person, l10n.director, director),
        if (studio.isNotEmpty)
          _buildStaffRow(context, Icons.business, l10n.studio, studio),
      ],
    );
  }

  Widget _buildStaffRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBangumi(int subjectId) async {
    final uri = Uri.parse('https://bgm.tv/subject/$subjectId');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeFromShelfQuestion),
        content: Text(l10n.removeFromShelfConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(shelfRepositoryProvider).deleteEntry(entryId);
      if (context.mounted) {
        context.pop();
      }
    }
  }

  /// Builds the detail poster with fallback chain:
  /// local large file -> largePosterUrl -> posterUrl -> placeholder.
  Widget _buildDetailPoster(
    BuildContext context, {
    required String localLargePath,
    required String largePosterUrl,
    required String posterUrl,
  }) {
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );

    // 1. Try local large file
    if (localLargePath.isNotEmpty) {
      final file = File(localLargePath);
      return Image(
        image: FileImage(file),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) {
          // Local file missing/corrupt — fall through to network
          return _buildNetworkPoster(largePosterUrl, posterUrl, placeholder);
        },
      );
    }

    return _buildNetworkPoster(largePosterUrl, posterUrl, placeholder);
  }

  Widget _buildNetworkPoster(
    String largePosterUrl,
    String posterUrl,
    Widget placeholder,
  ) {
    // 2. Try large network URL
    if (largePosterUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: largePosterUrl,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) {
          // 3. Try medium/poster URL as final network fallback
          if (posterUrl.isNotEmpty && posterUrl != largePosterUrl) {
            return CachedNetworkImage(
              imageUrl: posterUrl,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => placeholder,
            );
          }
          return placeholder;
        },
      );
    }

    // 3. Try poster URL directly
    if (posterUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: posterUrl,
        fit: BoxFit.contain,
        errorWidget: (_, _, _) => placeholder,
      );
    }

    return placeholder;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

/// Bottom sheet widget for moving an entry to a different tier.
class _TierMoveSheet extends ConsumerWidget {
  final int entryId;
  final int currentTierId;

  const _TierMoveSheet({required this.entryId, required this.currentTierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiersAsync = ref.watch(shelfTiersProvider);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.moveToTier,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          tiersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(l10n.errorWithDetails(e.toString())),
            data: (tiers) => Column(
              children: tiers.map((tierData) {
                final tier = tierData.tier;
                final isCurrentTier = tier.id == currentTierId;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(tier.colorValue),
                    radius: 14,
                    child: tier.emoji.isNotEmpty
                        ? Text(tier.emoji, style: const TextStyle(fontSize: 14))
                        : null,
                  ),
                  title: Text(tier.name),
                  trailing: isCurrentTier
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  enabled: !isCurrentTier,
                  onTap: () => _moveToTier(context, ref, tier.id),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToTier(
    BuildContext context,
    WidgetRef ref,
    int targetTierId,
  ) async {
    final repo = ref.read(shelfRepositoryProvider);

    // Place at the end of the target tier
    final rank = RankUtils.insertRank(null, null);

    await repo.moveEntry(
      entryId: entryId,
      targetTierId: targetTierId,
      newRank: rank,
    );

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
