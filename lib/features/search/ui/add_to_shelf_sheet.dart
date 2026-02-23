import 'dart:async';

import 'package:anime_shelf/core/providers.dart';
import 'package:anime_shelf/features/search/data/bangumi_subject.dart';
import 'package:anime_shelf/features/search/providers/search_provider.dart';
import 'package:anime_shelf/features/shelf/providers/shelf_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Bottom sheet for adding a Bangumi subject to the shelf.
///
/// Shows a list of available tiers. On selection, caches the
/// subject locally and creates an entry in the chosen tier.
class AddToShelfSheet extends ConsumerWidget {
  final BangumiSubject subject;

  const AddToShelfSheet({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiersAsync = ref.watch(shelfTiersProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add to Shelf',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            subject.nameCn.isNotEmpty ? subject.nameCn : subject.name,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          tiersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (tiers) => Column(
              children: tiers.map((tierData) {
                final tier = tierData.tier;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(tier.colorValue),
                    radius: 14,
                    child: tier.emoji.isNotEmpty
                        ? Text(tier.emoji, style: const TextStyle(fontSize: 14))
                        : null,
                  ),
                  title: Text(tier.name),
                  onTap: () => _addToTier(context, ref, tier.id),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToTier(
    BuildContext context,
    WidgetRef ref,
    int tierId,
  ) async {
    final searchRepo = ref.read(searchRepositoryProvider);
    final shelfRepo = ref.read(shelfRepositoryProvider);

    // Check if already on shelf
    final exists = await shelfRepo.subjectExists(subject.id);
    if (exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Already on your shelf')));
        Navigator.of(context).pop();
      }
      return;
    }

    // Cache subject locally, then create entry
    await searchRepo.cacheSubject(subject);
    await shelfRepo.createEntry(subjectId: subject.id, tierId: tierId);

    // Trigger background image download (fire-and-forget).
    final imageService = ref.read(localImageServiceProvider);
    final largeUrl = subject.images?.large ?? '';
    final mediumUrl = subject.images?.medium ?? '';
    unawaited(
      imageService.downloadAndProcess(
        subjectId: subject.id,
        largeUrl: largeUrl,
        mediumUrl: mediumUrl,
      ),
    );

    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Added to shelf')));
    }
  }
}
