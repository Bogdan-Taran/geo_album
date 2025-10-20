final router = GoRouter(
  initialLocation: '/features/views/',
  routes: [
    // BottomNavigationBar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/views',
              builder: (context, state) => const GalleryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/views',
              builder: (context, state) => const PhotoLookingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/views',
              builder: (context, state) => const MapPhotos(),
            ),
          ],
        ),
      ],
    ),
  ],
);