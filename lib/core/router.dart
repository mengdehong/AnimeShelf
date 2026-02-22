import 'package:anime_shelf/features/details/ui/details_page.dart';
import 'package:anime_shelf/features/search/ui/search_page.dart';
import 'package:anime_shelf/features/settings/ui/settings_page.dart';
import 'package:anime_shelf/features/shelf/ui/shelf_page.dart';
import 'package:go_router/go_router.dart';

/// App-level router configuration using go_router.
final appRouter = GoRouter(
  initialLocation: '/shelf',
  routes: [
    GoRoute(path: '/shelf', builder: (context, state) => const ShelfPage()),
    GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
    GoRoute(
      path: '/details/:entryId',
      builder: (context, state) {
        final entryId = int.parse(state.pathParameters['entryId']!);
        return DetailsPage(entryId: entryId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
