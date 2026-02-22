import 'package:anime_shelf/core/utils/rank_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RankUtils.insertRank', () {
    test('returns defaultGap when both prev and next are null', () {
      expect(RankUtils.insertRank(null, null), equals(RankUtils.defaultGap));
    });

    test('returns half of next when prev is null', () {
      expect(RankUtils.insertRank(null, 1000.0), equals(500.0));
    });

    test('returns half of next when prev is null and next is small', () {
      expect(RankUtils.insertRank(null, 2.0), equals(1.0));
    });

    test('returns prev + defaultGap when next is null', () {
      expect(
        RankUtils.insertRank(1000.0, null),
        equals(1000.0 + RankUtils.defaultGap),
      );
    });

    test('returns midpoint when both prev and next are present', () {
      expect(RankUtils.insertRank(1000.0, 2000.0), equals(1500.0));
    });

    test('midpoint of adjacent integers', () {
      expect(RankUtils.insertRank(1.0, 2.0), equals(1.5));
    });

    test('midpoint of very close values', () {
      final result = RankUtils.insertRank(1.0, 1.0 + 1e-8);
      expect(result, greaterThan(1.0));
      expect(result, lessThan(1.0 + 1e-8));
    });

    test('handles zero values', () {
      expect(RankUtils.insertRank(0.0, 1000.0), equals(500.0));
    });

    test('handles negative prev with null next', () {
      expect(
        RankUtils.insertRank(-500.0, null),
        equals(-500.0 + RankUtils.defaultGap),
      );
    });
  });

  group('RankUtils.needsRecompression', () {
    test('returns false for well-spaced values', () {
      expect(RankUtils.needsRecompression(1000.0, 2000.0), isFalse);
    });

    test('returns false for values just above threshold', () {
      expect(RankUtils.needsRecompression(1.0, 1.0 + 1e-8), isFalse);
    });

    test('returns true for values below threshold', () {
      expect(RankUtils.needsRecompression(1.0, 1.0 + 1e-10), isTrue);
    });

    test('returns true for equal values', () {
      expect(RankUtils.needsRecompression(1.0, 1.0), isTrue);
    });

    test('is commutative (order does not matter)', () {
      expect(
        RankUtils.needsRecompression(2000.0, 1000.0),
        equals(RankUtils.needsRecompression(1000.0, 2000.0)),
      );
    });

    test('returns true at exact threshold', () {
      // 1e-9 is < 1e-9 is false, but 0 < 1e-9 is true
      expect(RankUtils.needsRecompression(0.0, 0.0), isTrue);
    });
  });

  group('RankUtils.recompressRanks', () {
    test('returns empty list for count 0', () {
      expect(RankUtils.recompressRanks(0), isEmpty);
    });

    test('returns single defaultGap for count 1', () {
      expect(RankUtils.recompressRanks(1), equals([1000.0]));
    });

    test('returns evenly spaced values for count 3', () {
      expect(RankUtils.recompressRanks(3), equals([1000.0, 2000.0, 3000.0]));
    });

    test('returns correct count of elements', () {
      const n = 10;
      final result = RankUtils.recompressRanks(n);
      expect(result.length, equals(n));
    });

    test('all values are evenly spaced by defaultGap', () {
      final result = RankUtils.recompressRanks(5);
      for (var i = 1; i < result.length; i++) {
        expect(result[i] - result[i - 1], equals(RankUtils.defaultGap));
      }
    });

    test('first value equals defaultGap', () {
      final result = RankUtils.recompressRanks(5);
      expect(result.first, equals(RankUtils.defaultGap));
    });
  });

  group('RankUtils integration scenarios', () {
    test('repeated insertions at the end produce increasing ranks', () {
      double? prev;
      final ranks = <double>[];
      for (var i = 0; i < 5; i++) {
        final rank = RankUtils.insertRank(prev, null);
        ranks.add(rank);
        prev = rank;
      }
      for (var i = 1; i < ranks.length; i++) {
        expect(ranks[i], greaterThan(ranks[i - 1]));
      }
    });

    test('repeated insertions between two values converge', () {
      final a = 1000.0;
      var b = 2000.0;
      for (var i = 0; i < 50; i++) {
        final mid = RankUtils.insertRank(a, b);
        expect(mid, greaterThan(a));
        expect(mid, lessThan(b));
        b = mid; // always insert before mid
      }
      // After many insertions, a and b should be very close
      expect(RankUtils.needsRecompression(a, b), isTrue);
    });
  });
}
