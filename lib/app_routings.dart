import 'package:go_router/go_router.dart';
import '/gallery_screen.dart';
import '/photo_looking_screen.dart';
import '/map_photos.dart';
import '/root_screen.dart';




final router = GoRouter(
  initialLocation: '/gallery',
  routes: [
    // BottomNavigationBar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/gallery',
              builder: (context, state) => const GalleryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/photo',
              builder: (context, state) => const PhotoLookingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapPhotosScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);