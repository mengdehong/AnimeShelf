import 'package:anime_shelf/core/theme/app_theme.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A single entry card displaying the anime poster and title.
///
/// Uses [CachedNetworkImage] for offline-capable poster loading
/// with a shimmer-like placeholder.
class EntryCard extends StatelessWidget {
  final EntryWithSubject entryData;
  final VoidCallback onTap;

  const EntryCard({super.key, required this.entryData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final subject = entryData.subject;
    final metrics = Theme.of(context).extension<AppThemeMetrics>();
    final title = subject?.nameCn.isNotEmpty == true
        ? subject!.nameCn
        : (subject?.nameJp ?? 'Unknown');
    final posterUrl = subject?.posterUrl ?? '';
    final posterRadius = metrics?.posterRadius ?? 12;

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'entry-poster-${entryData.entry.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(posterRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster image
              if (posterUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.movie_outlined, size: 32),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined, size: 32),
                    ),
                  ),
                )
              else
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: Icon(Icons.movie_outlined, size: 32),
                  ),
                ),

              // Title overlay at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
