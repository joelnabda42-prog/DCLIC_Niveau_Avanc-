import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:agroalert_ai_plus/providers/service_providers.dart';
import 'package:agroalert_ai_plus/screens/login_screen.dart';

import '../mocks/mock_services.dart';

/// Test de parcours utilisateur : "Se connecter à l'application".
///
/// Scénario 1 — Champs invalides :
///   Étant donné le formulaire de connexion vide,
///   Quand l'utilisateur appuie sur "Se connecter",
///   Alors des messages de validation s'affichent et aucune navigation
///   n'a lieu.
///
/// Scénario 2 — Connexion réussie :
///   Étant donné un email et un mot de passe valides,
///   Quand l'utilisateur appuie sur "Se connecter" et que Firebase Auth
///   répond avec succès (mocké),
///   Alors l'utilisateur est redirigé vers le Dashboard.
void main() {
  late MockAuthService authService;

  Widget buildTestApp() {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('DASHBOARD_PLACEHOLDER'))),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('REGISTER_PLACEHOLDER'))),
        ),
      ],
    );

    return ProviderScope(
      overrides: [authServiceProvider.overrideWithValue(authService)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  setUp(() {
    authService = MockAuthService();
  });

  testWidgets('affiche des erreurs de validation si le formulaire est vide', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pump();

    expect(find.text('Email requis'), findsOneWidget);
    expect(find.text('6 caractères minimum'), findsOneWidget);
    // Aucune navigation n'a dû avoir lieu.
    expect(find.text('DASHBOARD_PLACEHOLDER'), findsNothing);
  });

  testWidgets('redirige vers le Dashboard après une connexion réussie', (tester) async {
    when(() => authService.signIn(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async => MockUserCredential());

    await tester.pumpWidget(buildTestApp());

    await tester.enterText(find.byType(TextFormField).first, 'demo@agroalert.ai');
    await tester.enterText(find.byType(TextFormField).last, 'password123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD_PLACEHOLDER'), findsOneWidget);
  });

  testWidgets('affiche un message d\'erreur si les identifiants sont incorrects', (tester) async {
    when(() => authService.signIn(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(Exception('wrong-password'));

    await tester.pumpWidget(buildTestApp());

    await tester.enterText(find.byType(TextFormField).first, 'demo@agroalert.ai');
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD_PLACEHOLDER'), findsNothing);
    // Un message d'erreur générique doit être affiché à l'utilisateur.
    expect(find.textContaining('erreur'), findsWidgets);
  });
}
