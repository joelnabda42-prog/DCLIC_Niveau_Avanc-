import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/crop_analysis.dart';
import '../providers/auth_providers.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/scanner_screen.dart';
import '../screens/result_screen.dart';
import '../screens/history_screen.dart';
import '../screens/map_screen.dart';
import '../screens/weather_screen.dart';
import '../screens/profile_screen.dart';

/// Centralise tous les noms de routes de l'application.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String scanner = '/scanner';
  static const String result = '/result';
  static const String history = '/history';
  static const String map = '/map';
  static const String weather = '/weather';
  static const String profile = '/profile';
}

/// Provider Riverpod exposant la configuration GoRouter.
///
/// La redirection est branchée sur [authStateChangesProvider] :
/// - un utilisateur non connecté est renvoyé vers /login,
/// - un utilisateur connecté ne peut pas revenir sur /login ou /register,
/// - le SplashScreen gère lui-même sa propre temporisation avant de
///   décider vers où rediriger (voir splash_screen.dart).
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final currentPath = state.matchedLocation;
      final isSplash = currentPath == AppRoutes.splash;
      final isAuthRoute = currentPath == AppRoutes.login || currentPath == AppRoutes.register;

      // Le splash gère sa propre navigation le temps que Firebase
      // détermine l'état de connexion (évite un flash de contenu).
      if (isSplash) return null;

      final isLoggedIn = authState.value != null;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanner,
        name: 'scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.result,
        name: 'result',
        // L'analyse diagnostiquée est transmise via `extra` depuis
        // ScannerScreen (context.go(AppRoutes.result, extra: analysis)).
        builder: (context, state) => ResultScreen(analysis: state.extra as CropAnalysis?),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.map,
        name: 'map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: AppRoutes.weather,
        name: 'weather',
        builder: (context, state) => const WeatherScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
