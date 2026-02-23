import 'package:anime_shelf/core/theme/app_theme.dart';
import 'package:anime_shelf/features/shelf/data/shelf_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A single entry card displaying the anime poster and title.
///
/// Uses [CachedNetworkImage] for offline-capable poster loading
/// with a shimmer-like placeholder.
class EntryCard extends StatelessWidget {
  static const _posterCacheWidth = 330;
  static const _posterCacheHeight = 480;

  final EntryWithSubject entryData;
  final VoidCallback onTap;

  const EntryCard({super.key, required this.entryData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subject = entryData.subject;
    final metrics = theme.extension<AppThemeMetrics>();
    final title = subject?.nameCn.isNotEmpty == true
        ? subject!.nameCn
        : (subject?.nameJp ?? 'Unknown');
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
              // Poster image
              if (posterUrl.isNotEmpty)
                CachedNetworkImage(
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
                    child: const Center(
                      child: Icon(Icons.movie_outlined, size: 32),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: placeholderColor,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined, size: 32),
                    ),
                  ),
                )
              else
                Container(
                  color: placeholderColor,
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
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 6,
                    top: 24, // 增加顶部内边距让渐变更平滑
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8), // 底部较深的黑色遮罩
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white, // 纯白字体在深色渐变上最清晰
                      fontSize: 11, // 稍微调小字体适应长标题
                      fontWeight: FontWeight.w800, // 更粗的字体，增强辨识度
                      height: 1.1,
                      letterSpacing: 0.3,
                      shadows: [
                        // 外层描边效果 (多向小偏移阴影模拟描边)
                        Shadow(
                          color: Colors.black87,
                          offset: Offset(-1, -1),
                          blurRadius: 1,
                        ),
                        Shadow(
                          color: Colors.black87,
                          offset: Offset(1, -1),
                          blurRadius: 1,
                        ),
                        Shadow(
                          color: Colors.black87,
                          offset: Offset(-1, 1),
                          blurRadius: 1,
                        ),
                        Shadow(
                          color: Colors.black87,
                          offset: Offset(1, 1),
                          blurRadius: 1,
                        ),
                        // 底部较宽的扩散阴影，增加质感
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
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
