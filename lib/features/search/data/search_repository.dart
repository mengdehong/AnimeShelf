import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/network/bangumi_client.dart';
import 'package:anime_shelf/features/search/data/bangumi_subject.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

/// Repository for Bangumi API search and subject fetching.
///
/// Handles searching anime, fetching subject details, and
/// caching results into the local Drift database.
class SearchRepository {
  final BangumiClient _client;
  final AppDatabase _db;

  SearchRepository(this._client, this._db);

  /// Searches Bangumi for anime subjects matching [keyword].
  ///
  /// Uses the v0 POST `/v0/search/subjects` endpoint with
  /// filter `type: [2]` (anime).
  Future<List<BangumiSubject>> searchSubjects(
    String keyword, {
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/v0/search/subjects',
        data: {
          'keyword': keyword,
          'filter': {
            'type': [2],
          },
        },
        queryParameters: {'offset': offset, 'limit': limit},
      );

      final parsed = BangumiSearchResponse.fromJson(response.data!);
      return parsed.data;
    } on DioException catch (e) {
      _client.throwApiException(e);
    }
  }

  /// Fetches a single subject's full details from Bangumi.
  Future<BangumiSubject> fetchSubject(int subjectId) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/v0/subjects/$subjectId',
      );
      return BangumiSubject.fromJson(response.data!);
    } on DioException catch (e) {
      _client.throwApiException(e);
    }
  }

  /// Caches a Bangumi subject into the local database.
  Future<void> cacheSubject(BangumiSubject subject) async {
    await _db
        .into(_db.subjects)
        .insertOnConflictUpdate(
          SubjectsCompanion.insert(
            subjectId: Value(subject.id),
            nameCn: Value(subject.nameCn),
            nameJp: Value(subject.name),
            posterUrl: Value(_thumbnailPosterUrl(subject.images)),
            airDate: Value(subject.airDate),
            eps: Value(subject.eps),
            rating: Value(subject.rating?.score ?? 0.0),
            summary: Value(subject.summary),
          ),
        );
  }

  String _thumbnailPosterUrl(BangumiImages? images) {
    if (images == null) {
      return '';
    }
    if (images.medium.isNotEmpty) {
      return images.medium;
    }
    if (images.small.isNotEmpty) {
      return images.small;
    }
    if (images.grid.isNotEmpty) {
      return images.grid;
    }
    return images.large;
  }

  /// Refreshes a cached subject from the API.
  Future<void> refreshSubject(int subjectId) async {
    final subject = await fetchSubject(subjectId);
    await cacheSubject(subject);
  }
}
