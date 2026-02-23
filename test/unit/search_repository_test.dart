import 'package:anime_shelf/core/database/app_database.dart';
import 'package:anime_shelf/core/exceptions/api_exception.dart';
import 'package:anime_shelf/core/network/bangumi_client.dart';
import 'package:anime_shelf/features/search/data/bangumi_subject.dart';
import 'package:anime_shelf/features/search/data/search_repository.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBangumiClient extends Mock implements BangumiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late AppDatabase db;
  late MockBangumiClient mockClient;
  late MockDio mockDio;
  late SearchRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockClient = MockBangumiClient();
    mockDio = MockDio();
    when(() => mockClient.dio).thenReturn(mockDio);
    repo = SearchRepository(mockClient, db);
  });

  tearDown(() async {
    await db.close();
  });

  group('searchSubjects', () {
    test('returns parsed BangumiSubject list on success', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/v0/search/subjects',
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            'total': 1,
            'data': [
              {
                'id': 42,
                'name': 'Steins;Gate',
                'name_cn': 'Steins;Gate 命运石之门',
                'summary': 'Time travel',
                'air_date': '2011-04-06',
                'eps': 24,
                'images': {
                  'large': 'https://example.com/large.jpg',
                  'medium': '',
                  'small': '',
                  'grid': '',
                },
                'rating': {'score': 9.1, 'total': 10000},
              },
            ],
          },
          requestOptions: RequestOptions(path: '/v0/search/subjects'),
          statusCode: 200,
        ),
      );

      final results = await repo.searchSubjects('steins');
      expect(results.length, equals(1));
      expect(results[0].id, equals(42));
      expect(results[0].name, equals('Steins;Gate'));
      expect(results[0].nameCn, equals('Steins;Gate 命运石之门'));
      expect(results[0].eps, equals(24));
      expect(results[0].rating?.score, equals(9.1));
      expect(results[0].images?.large, equals('https://example.com/large.jpg'));
    });

    test('returns empty list when no results', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/v0/search/subjects',
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {'total': 0, 'data': <dynamic>[]},
          requestOptions: RequestOptions(path: '/v0/search/subjects'),
          statusCode: 200,
        ),
      );

      final results = await repo.searchSubjects('nonexistent');
      expect(results, isEmpty);
    });

    test('passes offset and limit as query parameters', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/v0/search/subjects',
          data: any(named: 'data'),
          queryParameters: {'offset': 10, 'limit': 5},
        ),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {'total': 0, 'data': <dynamic>[]},
          requestOptions: RequestOptions(path: '/v0/search/subjects'),
          statusCode: 200,
        ),
      );

      await repo.searchSubjects('test', offset: 10, limit: 5);

      verify(
        () => mockDio.post<Map<String, dynamic>>(
          '/v0/search/subjects',
          data: any(named: 'data'),
          queryParameters: {'offset': 10, 'limit': 5},
        ),
      ).called(1);
    });

    test('throws ApiException on DioException', () async {
      final dioError = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/v0/search/subjects'),
      );

      when(
        () => mockDio.post<Map<String, dynamic>>(
          '/v0/search/subjects',
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(dioError);

      when(
        () => mockClient.throwApiException(dioError),
      ).thenThrow(const NetworkTimeoutException());

      expect(
        () => repo.searchSubjects('test'),
        throwsA(isA<NetworkTimeoutException>()),
      );
    });
  });

  group('fetchSubject', () {
    test('returns parsed single subject', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('/v0/subjects/42'),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            'id': 42,
            'name': 'Steins;Gate',
            'name_cn': '命运石之门',
            'summary': 'Time travel',
            'air_date': '2011-04-06',
            'eps': 24,
            'images': {
              'large': 'https://example.com/l.jpg',
              'medium': '',
              'small': '',
              'grid': '',
            },
            'rating': {'score': 9.1, 'total': 10000},
          },
          requestOptions: RequestOptions(path: '/v0/subjects/42'),
          statusCode: 200,
        ),
      );

      final subject = await repo.fetchSubject(42);
      expect(subject.id, equals(42));
      expect(subject.nameCn, equals('命运石之门'));
    });
  });

  group('cacheSubject', () {
    test('prefers medium poster URL for shelf thumbnails', () async {
      const subject = BangumiSubject(
        id: 7,
        name: 'Sample',
        images: BangumiImages(
          large: 'https://example.com/large.jpg',
          medium: 'https://example.com/medium.jpg',
          small: 'https://example.com/small.jpg',
        ),
      );

      await repo.cacheSubject(subject);

      final cached = await (db.select(
        db.subjects,
      )..where((s) => s.subjectId.equals(7))).getSingle();
      expect(cached.posterUrl, equals('https://example.com/medium.jpg'));
    });

    test('inserts subject into database', () async {
      const subject = BangumiSubject(
        id: 42,
        name: 'Steins;Gate',
        nameCn: '命运石之门',
        summary: 'Time travel',
        airDate: '2011-04-06',
        eps: 24,
        images: BangumiImages(large: 'https://example.com/l.jpg'),
        rating: BangumiRating(score: 9.1, total: 10000),
      );

      await repo.cacheSubject(subject);

      final cached = await (db.select(
        db.subjects,
      )..where((s) => s.subjectId.equals(42))).getSingle();
      expect(cached.nameCn, equals('命运石之门'));
      expect(cached.nameJp, equals('Steins;Gate'));
      expect(cached.posterUrl, equals('https://example.com/l.jpg'));
      expect(cached.rating, equals(9.1));
    });

    test('updates existing subject on conflict', () async {
      const subject1 = BangumiSubject(
        id: 42,
        name: 'Steins;Gate',
        nameCn: 'Old Name',
        rating: BangumiRating(score: 8.0),
      );
      const subject2 = BangumiSubject(
        id: 42,
        name: 'Steins;Gate',
        nameCn: 'New Name',
        rating: BangumiRating(score: 9.1),
      );

      await repo.cacheSubject(subject1);
      await repo.cacheSubject(subject2);

      final subjects = await db.select(db.subjects).get();
      final matching = subjects.where((s) => s.subjectId == 42).toList();
      expect(matching.length, equals(1));
      expect(matching[0].nameCn, equals('New Name'));
      expect(matching[0].rating, equals(9.1));
    });

    test('handles subject with null images', () async {
      const subject = BangumiSubject(id: 99, name: 'No Image');

      await repo.cacheSubject(subject);

      final cached = await (db.select(
        db.subjects,
      )..where((s) => s.subjectId.equals(99))).getSingle();
      expect(cached.posterUrl, isEmpty);
    });
  });

  group('refreshSubject', () {
    test('fetches and caches subject', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>('/v0/subjects/42'),
      ).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: {
            'id': 42,
            'name': 'Steins;Gate',
            'name_cn': '命运石之门',
            'summary': 'Updated summary',
            'air_date': '2011-04-06',
            'eps': 25,
            'rating': {'score': 9.2, 'total': 11000},
          },
          requestOptions: RequestOptions(path: '/v0/subjects/42'),
          statusCode: 200,
        ),
      );

      await repo.refreshSubject(42);

      final cached = await (db.select(
        db.subjects,
      )..where((s) => s.subjectId.equals(42))).getSingle();
      expect(cached.summary, equals('Updated summary'));
      expect(cached.eps, equals(25));
    });
  });
}
