import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/screens/history_screen.dart';
import 'package:userapp/screens/home_screen.dart';
import 'package:userapp/screens/login_screen.dart';
import 'package:userapp/screens/main_shell.dart';
import 'package:userapp/screens/map_screen.dart';
import 'package:userapp/screens/profile_screen.dart';
import 'package:userapp/screens/register_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final showRegisteredDialog =
              state.uri.queryParameters['registered'] == '1';

          return LoginScreen(showRegisteredDialog: showRegisteredDialog);
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';

      final isLoggedIn = auth.status == AuthStatus.authenticated;

      if (auth.status == AuthStatus.loading || auth.status == AuthStatus.initial) {
        return null;
      }

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },
  );
});