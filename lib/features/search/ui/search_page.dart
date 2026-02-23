import 'package:anime_shelf/core/theme/app_theme.dart';
import 'package:anime_shelf/core/window/fused_app_bar.dart';
import 'package:anime_shelf/features/search/data/bangumi_subject.dart';
import 'package:anime_shelf/features/search/providers/search_provider.dart';
import 'package:anime_shelf/features/search/ui/add_to_shelf_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Search page — keyword search against the Bangumi API.
///
/// Shows a text field with debounced search, skeleton loading,
/// and result tiles with an "add to shelf" action.
class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: FusedAppBar(
        titleSpacing: 0,
        title: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search anime...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).update(value);
          },
        ),
      ),
      body: resultsAsync.when(
        loading: () => _buildSkeletonList(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Search failed: $error'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(searchResultsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (results) {
          if (results.isEmpty) {
            final query = ref.read(searchQueryProvider);
            if (query.trim().isEmpty) {
              return const Center(child: Text('Type to search Bangumi'));
            }
            return const Center(child: Text('No results found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return _SearchResultTile(subject: results[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const _SkeletonTile();
      },
    );
  }
}

/// A single search result tile showing poster, title, year, and rating.
class _SearchResultTile extends ConsumerWidget {
  final BangumiSubject subject;

  const _SearchResultTile({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = subject.nameCn.isNotEmpty ? subject.nameCn : subject.name;
    final subtitle = subject.name;
    final posterUrl = subject.images?.medium ?? '';
    final rating = subject.rating?.score ?? 0.0;
    final metrics = Theme.of(context).extension<AppThemeMetrics>();
    final posterRadius = metrics?.posterRadius ?? 8;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(posterRadius),
        child: SizedBox(
          width: 48,
          height: 68,
          child: posterUrl.isNotEmpty
              ? Image.network(
                  posterUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 144,
                  errorBuilder: (_, _, _) => Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.movie_outlined),
                  ),
                )
              : Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.movie_outlined),
                ),
        ),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != title)
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          Row(
            children: [
              if (subject.airDate.isNotEmpty) ...[
                Text(
                  subject.airDate.length >= 4
                      ? subject.airDate.substring(0, 4)
                      : subject.airDate,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
              ],
              if (rating > 0) ...[
                Icon(
                  Icons.star,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 2),
                Text(
                  rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (context) => AddToShelfSheet(subject: subject),
          );
        },
      ),
    );
  }
}

/// Skeleton loading tile for search results.
class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final metrics = Theme.of(context).extension<AppThemeMetrics>();
    final tileRadius = metrics?.tileRadius ?? 4;
    final posterRadius = metrics?.posterRadius ?? 8;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(posterRadius),
        child: Container(width: 48, height: 68, color: shimmerColor),
      ),
      title: Container(
        height: 14,
        width: double.infinity,
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(tileRadius),
        ),
      ),
      subtitle: Container(
        height: 10,
        width: 120,
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          color: shimmerColor,
          borderRadius: BorderRadius.circular(tileRadius),
        ),
      ),
    );
  }
}
