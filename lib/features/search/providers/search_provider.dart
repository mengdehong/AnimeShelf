import 'dart:async';

import 'package:anime_shelf/core/providers.dart';
import 'package:anime_shelf/features/search/data/bangumi_subject.dart';
import 'package:anime_shelf/features/search/data/search_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

/// Provides the search repository instance.
@Riverpod(keepAlive: true)
SearchRepository searchRepository(SearchRepositoryRef ref) {
  return SearchRepository(
    ref.watch(bangumiClientProvider),
    ref.watch(databaseProvider),
  );
}

/// Holds the current search query string.
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

/// Fetches search results with debouncing.
///
/// Watches [searchQueryProvider] and triggers a Bangumi API search
/// after the query settles for 400ms.
@riverpod
Future<List<BangumiSubject>> searchResults(SearchResultsRef ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) {
    return [];
  }

  // Debounce: wait 400ms before firing request
  await Future<void>.delayed(const Duration(milliseconds: 400));

  // If query changed during the delay, this provider is already
  // being rebuilt — the ref will be disposed, so this is safe.
  final repo = ref.read(searchRepositoryProvider);
  return repo.searchSubjects(query.trim());
}
