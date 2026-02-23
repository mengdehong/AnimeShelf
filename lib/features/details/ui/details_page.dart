import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/features/details/providers/details_provider.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Immersive detail page for an entry.
///
/// Features a large poster header, metadata display,
/// and a private notes editor.
class DetailsPage extends HookConsumerWidget {
  final int entryId;

  const DetailsPage({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(entryDetailProvider(entryId));

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load details: $error'),
            ],
          ),
        ),
        data: (detail) {
          if (detail == null) {
            return const Center(child: Text('Entry not found'));
          }
          return _DetailsContent(
            entryId: entryId,
            entry: detail.entry,
            subject: detail.subject,
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

  const _DetailsContent({
    required this.entryId,
    required this.entry,
    this.subject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteController = useTextEditingController(text: entry.note);
    final posterUrl = subject?.posterUrl ?? '';
    final title = (subject?.nameCn.isNotEmpty == true)
        ? subject!.nameCn
        : (subject?.nameJp ?? 'Unknown');
    final originalTitle = subject?.nameJp ?? '';
    final airDate = subject?.airDate ?? '';
    final rating = subject?.rating ?? 0.0;
    final summary = subject?.summary ?? '';

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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove from shelf',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Remove from shelf?'),
                      content: const Text(
                        'Are you sure you want to remove this anime from your shelf? '
                        'This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await ref
                        .read(shelfRepositoryProvider)
                        .deleteEntry(entryId);
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                },
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'entry-poster-$entryId',
                  child: posterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: posterUrl,
                          fit: BoxFit.contain,
                        )
                      : Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
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
                // Info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (airDate.isNotEmpty)
                      Chip(
                        avatar: const Icon(Icons.calendar_today, size: 16),
                        label: Text(airDate),
                      ),
                    if (rating > 0)
                      Chip(
                        avatar: const Icon(Icons.star, size: 16),
                        label: Text(rating.toStringAsFixed(1)),
                      ),
                  ],
                ),

                // Summary
                if (summary.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(summary, style: Theme.of(context).textTheme.bodyMedium),
                ],

                // Notes
                const SizedBox(height: 24),
                Text(
                  'Private Notes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteController,
                  maxLines: null,
                  minLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write your thoughts...',
                  ),
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
}
