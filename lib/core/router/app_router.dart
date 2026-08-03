import 'package:go_router/go_router.dart';
import '../providers/app_state.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/login/login_screen.dart';
import '../../views/main_layout.dart';

class AppRouter {
  static bool _hasFinishedSplash = false;

  static GoRouter createRouter(AppState appState) {
    return GoRouter(
      initialLocation: _hasFinishedSplash ? (appState.isLoggedIn ? '/' : '/login') : '/splash',
      refreshListenable: appState,
      redirect: (context, state) {
        final isLoggedIn = appState.isLoggedIn;
        final isSplash = state.matchedLocation == '/splash';
        final isLoggingIn = state.matchedLocation == '/login';

        // Allow splash screen animation to play once on app startup
        if (isSplash) {
          if (_hasFinishedSplash) {
            return isLoggedIn ? '/' : '/login';
          }
          return null;
        }

        // Mark splash as finished once initial navigation occurs
        _hasFinishedSplash = true;

        // Redirect unauthenticated users to /login
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        // Redirect authenticated users from /login to home /
        if (isLoggedIn && isLoggingIn) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const MainLayout(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) {
            appState.setTabIndex(0);
            return const MainLayout();
          },
        ),
        GoRoute(
          path: '/programs',
          name: 'programs',
          builder: (context, state) {
            appState.setTabIndex(1);
            return const MainLayout();
          },
        ),
        GoRoute(
          path: '/schedule',
          name: 'schedule',
          builder: (context, state) {
            appState.setTabIndex(2);
            return const MainLayout();
          },
        ),
        GoRoute(
          path: '/live',
          name: 'live',
          builder: (context, state) {
            appState.setTabIndex(3);
            return const MainLayout();
          },
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) {
            appState.setTabIndex(appState.userRole == 'Super Admin' ? 4 : 6);
            return const MainLayout();
          },
        ),
      ],
    );
  }
}
