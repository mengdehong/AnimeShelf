/// Utility functions for float-based rank insertion.
///
/// Used for both `entryRank` (within a tier) and `tierSort`
/// (ordering tiers on the shelf). New rank is computed as the
/// midpoint between adjacent items. When the gap shrinks below
/// 1e-9, a full re-rank is triggered.
class RankUtils {
  RankUtils._();

  /// Default gap between newly created ranks.
  static const double defaultGap = 1000.0;

  /// Threshold below which adjacent ranks trigger re-compression.
  static const double compressionThreshold = 1e-9;

  /// Calculates a rank value to insert between [prev] and [next].
  ///
  /// - Both null → returns [defaultGap].
  /// - Only [prev] null → inserts before [next] (half of next).
  /// - Only [next] null → inserts after [prev] (prev + gap).
  /// - Both present → midpoint.
  static double insertRank(double? prev, double? next) {
    if (prev == null && next == null) {
      return defaultGap;
    }
    if (prev == null) {
      return next! / 2;
    }
    if (next == null) {
      return prev + defaultGap;
    }
    return (prev + next) / 2;
  }

  /// Returns `true` when adjacent ranks [a] and [b] are too close
  /// and the tier needs re-compression.
  static bool needsRecompression(double a, double b) {
    return (b - a).abs() < compressionThreshold;
  }

  /// Re-assigns evenly-spaced ranks to a list of current rank values.
  ///
  /// Returns a list of new ranks in the same order, spaced by [defaultGap].
  static List<double> recompressRanks(int count) {
    return List.generate(count, (i) => (i + 1) * defaultGap);
  }
}
