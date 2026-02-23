import 'package:anime_shelf/features/details/ui/details_page.dart';
import 'package:anime_shelf/features/search/ui/search_page.dart';
import 'package:anime_shelf/features/settings/ui/settings_page.dart';
import 'package:anime_shelf/features/shelf/ui/shelf_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _quickPageDuration = Duration(milliseconds: 90);

CustomTransitionPage<void> _buildQuickFadePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: _quickPageDuration,
    reverseTransitionDuration: _quickPageDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
    child: child,
  );
}

/// App-level router configuration using go_router.
final appRouter = GoRouter(
  initialLocation: '/shelf',
  routes: [
    GoRoute(path: '/shelf', builder: (context, state) => const ShelfPage()),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) {
        return _buildQuickFadePage(state: state, child: const SearchPage());
      },
    ),
    GoRoute(
      path: '/details/:entryId',
      builder: (context, state) {
        final entryId = int.parse(state.pathParameters['entryId']!);
        return DetailsPage(entryId: entryId);
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) {
        return _buildQuickFadePage(state: state, child: const SettingsPage());
      },
    ),
  ],
);
