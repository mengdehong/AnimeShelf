import 'dart:io';

import 'package:anime_shelf/core/theme/app_theme.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:anime_shelf/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A single entry card displaying the anime poster and title.
///
/// Prefers a local thumbnail file when available, falling back
/// to [CachedNetworkImage] for network poster loading.
class EntryCard extends StatelessWidget {
  static const _posterCacheWidth = 330;
  static const _posterCacheHeight = 480;
  static const _defaultTitleFontSize = 11.5;

  final EntryWithSubject entryData;
  final VoidCallback onTap;
  final double titleFontSize;

  const EntryCard({
    super.key,
    required this.entryData,
    required this.onTap,
    this.titleFontSize = _defaultTitleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final subject = entryData.subject;
    final metrics = theme.extension<AppThemeMetrics>();
    final title = subject?.nameCn.isNotEmpty == true
        ? subject!.nameCn
        : (subject?.nameJp ?? l10n.unknown);
    final localThumbPath = subject?.localThumbnailPath ?? '';
    final posterUrl = subject?.posterUrl ?? '';
    final posterRadius = metrics?.posterRadius ?? 12;
    final placeholderColor = theme.colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'entry-poster-${entryData.entry.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(posterRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster image — local file first, network fallback
              _buildPosterImage(localThumbPath, posterUrl, placeholderColor),

              // Title overlay at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 6,
                    top: 54,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.96),
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      letterSpacing: 0.2,
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

  /// Builds the poster image widget.
  ///
  /// Priority: local thumbnail file -> CachedNetworkImage -> placeholder.
  Widget _buildPosterImage(
    String localThumbPath,
    String posterUrl,
    Color placeholderColor,
  ) {
    // Try local file first
    if (localThumbPath.isNotEmpty) {
      final file = File(localThumbPath);
      return Image(
        image: FileImage(file),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) {
          // Local file missing/corrupt — fall back to network
          return _buildNetworkOrPlaceholder(posterUrl, placeholderColor);
        },
      );
    }

    return _buildNetworkOrPlaceholder(posterUrl, placeholderColor);
  }

  Widget _buildNetworkOrPlaceholder(String posterUrl, Color placeholderColor) {
    if (posterUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: posterUrl,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        memCacheWidth: _posterCacheWidth,
        memCacheHeight: _posterCacheHeight,
        maxWidthDiskCache: _posterCacheWidth,
        maxHeightDiskCache: _posterCacheHeight,
        placeholder: (context, url) => Container(
          color: placeholderColor,
          child: const Center(child: Icon(Icons.movie_outlined, size: 32)),
        ),
        errorWidget: (context, url, error) => Container(
          color: placeholderColor,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 32),
          ),
        ),
      );
    }

    return Container(
      color: placeholderColor,
      child: const Center(child: Icon(Icons.movie_outlined, size: 32)),
    );
  }
}
